module Main where

import Database.HDBC
import Database.HDBC.Sqlite3

-- file Spec.hs
import Test.Hspec

-- Example Input of a normal user
normalUserInput :: String
normalUserInput = "john_doe"

-- Example of malicious input
maliciousInput :: String
maliciousInput = "' OR '1'='1' --"

-- UNSAFE: Direct string concatenation
unsafeQueryString :: Connection -> String -> IO [[SqlValue]]
unsafeQueryString conn userName = do
    -- DON'T DO THIS - Vulnerable to SQL injection
  let query = "SELECT * FROM users WHERE username = '" ++ userName ++ "'"
  quickQuery conn query []

-- SAFE: Running in a transaction with prepared statement
safeTransaction :: Connection -> String -> IO [[SqlValue]]
safeTransaction conn userName = do
    -- DO THIS - Combines prepared statements with transaction safety
  withTransaction conn $ \conn' -> do
    stmt <- prepare conn' "SELECT * FROM users WHERE username = ?"
    execute stmt [toSql userName]
    fetchAllRows stmt

-- Converts an row of SqlValues to a row of strings
-- used for comparisons.
rowToString :: [SqlValue] -> [String]
rowToString = map sqlValueToString

-- Converts an  SqlValue into a String
sqlValueToString :: SqlValue -> String
sqlValueToString (SqlInt64 i) = show i
sqlValueToString (SqlByteString bs) = "'" ++ show bs ++ "'"
sqlValueToString SqlNull = "NULL"
sqlValueToString x = error "Invalid Type: " <> show x

-- Query for ALL users. Used to test if Database was injected
allUsers :: IO [[String]]
allUsers = do
  connection <- connectSqlite3 "test.db" -- connect to sqlite db
  -- Run a query to retrieve all users
  result <- quickQuery' connection "SELECT * from users" []
  -- Wrap the result in IO to return IO [[String]]
  return $ map rowToString result

-- Query for only John Doe. Used to test if Database was properly queried
onlyJohn :: IO [[String]]
onlyJohn = do
  connection <- connectSqlite3 "test.db" -- connect to sqlite db
  -- Run a query to retrieve only John
  result <- quickQuery' connection "SELECT * from users WHERE username = ?" [toSql "john_doe"]
  -- Wrap the result in IO to return IO [[String]]
  return $ map rowToString result

main :: IO ()
main = hspec $ do
  describe "Unit Tests" $ do
    describe "Safe Transaction Unit Tests" $ do
      it "Querying for John returns John's Data" $ do
        do
          connection <- connectSqlite3 "test.db" -- connect to sqlite db
          -- Query for normalUserInput using `safeTransaction`
          result <- safeTransaction connection normalUserInput
          -- Receive the result for the john Query using HDBC-sqlite3
          onlyJohnResult <- onlyJohn -- get the result of querying normalUserInput
          -- If the Query using the safe Transaction is equal to the query for username john
          map rowToString result `shouldBe` onlyJohnResult -- then it passed

      it "Malicious Queries get no results" $ do
          -- Invalid inputs should NOT be allowed. Will return nothing.
          connection <- connectSqlite3 "test.db" -- connect to sqlite db
          -- Check if the result of the malicious input query is empty
          result <- null <$> safeTransaction connection maliciousInput
          result `shouldBe` True -- if it is empty, then it passed

    describe "Unsafe Query Unit Tests" $ do
      it "Querying for John returns John's data" $ do
        do
          connection <- connectSqlite3 "test.db" -- connect to sqlite db
          -- Query for normalUserInput using `unsafeQueryString`
          result <- unsafeQueryString connection normalUserInput
          -- Check the result for the john Query using HDBC-sqlite3
          onlyJohnResult <- onlyJohn -- get the result of querying normalUserInput
          map rowToString result `shouldBe` onlyJohnResult -- if it is not empty, then it passed

      it "VERY BAD: Malicious Input retrieves all User Data" $ do
        do
          connection <- connectSqlite3 "test.db" -- connect to sqlite db
          -- Do a query using malicious input
          result <- unsafeQueryString connection maliciousInput
          -- Get the result of querying all users
          allUsersResult <- allUsers
          -- malicious input retrieves all user data
          map rowToString result `shouldBe` allUsersResult

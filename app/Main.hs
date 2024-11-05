module Main where

import Database.HDBC
import Database.HDBC.Sqlite3
-- file Spec.hs
import Test.Hspec
import Test.QuickCheck
import Control.Exception (evaluate)

normalUserInput :: String
normalUserInput = "john_doe"

-- Example of how malicious input could exploit unsafe versions
maliciousExample :: String
maliciousExample = "' OR '1'='1' --"

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

main :: IO ()
main = hspec $ do
  describe "Unit Tests" $ do
    describe "Safe Transaction Unit Tests" $ do
      it "Returns Nothing for Invalid Inputs" $ do
          connection <- connectSqlite3 "test.db" -- connect to sqlite db
          result <- null <$> safeTransaction connection maliciousExample -- check if empty
          result `shouldBe` True -- if it is empty, then it passed

      it "Returns Something for Valid Inputs" $ do
        do
          connection <- connectSqlite3 "test.db" -- connect to sqlite db
          result <- null <$> safeTransaction connection normalUserInput -- check if empty
          result `shouldBe` False -- if it is not empty, then it passed

    describe "Unsafe Transaction Unit Tests" $ do
      it "Returns Something for Valid Inputs" $ do
        do
          connection <- connectSqlite3 "test.db" -- connect to sqlite db
          result <- null <$> unsafeQueryString connection normalUserInput -- check if empty
          result `shouldBe` False -- if it is not empty, then it passed

      it "VERY BAD: Returns Something for Invalid Inputs" $ do
        do
          connection <- connectSqlite3 "test.db" -- connect to sqlite db
          result <- null <$> unsafeQueryString connection maliciousExample -- check if empty
          result `shouldBe` False -- if it is not empty, then it passed

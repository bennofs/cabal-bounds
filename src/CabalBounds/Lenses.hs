{-# LANGUAGE TemplateHaskell, Rank2Types #-}

module CabalBounds.Lenses where

import Distribution.PackageDescription
import Distribution.Package
import Control.Lens
import Data.Data.Lens

makeLensesFor [ ("condLibrary"    , "condLibraryL")
              , ("condExecutables", "condExecutablesL")
              , ("condTestSuites" , "condTestSuitesL")
              , ("condBenchmarks" , "condBenchmarksL")
              ] ''GenericPackageDescription

makeLensesFor [ ("condTreeConstraints", "condTreeConstraintsL")
              ] ''CondTree

makeLensesFor [ ("exeName", "exeNameL")
              ] ''Executable

makeLensesFor [ ("testName", "testNameL")
              ] ''TestSuite

makeLensesFor [ ("benchmarkName", "benchmarkNameL")
              ] ''Benchmark

dependenciesOfLib :: Traversal' GenericPackageDescription [Dependency]
dependenciesOfLib = condLibraryL . _Just . biplate

dependenciesOfAllExes :: Traversal' GenericPackageDescription [Dependency]
dependenciesOfAllExes = condExecutablesL . traversed . _2 . biplate

dependenciesOfExe :: String -> Traversal' GenericPackageDescription [Dependency]
dependenciesOfExe exe = condExecutablesL . traversed . filtered ((== exe) . fst) . _2 . biplate

dependenciesOfAllTests :: Traversal' GenericPackageDescription [Dependency]
dependenciesOfAllTests = condTestSuitesL . traversed . _2 . biplate

dependenciesOfTest :: String -> Traversal' GenericPackageDescription [Dependency]
dependenciesOfTest test = condTestSuitesL . traversed . filtered ((== test) . fst) . _2 . biplate

dependenciesOfAllBenchms :: Traversal' GenericPackageDescription [Dependency]
dependenciesOfAllBenchms = condBenchmarksL . traversed . _2 . biplate

dependenciesOfBenchm :: String -> Traversal' GenericPackageDescription [Dependency]
dependenciesOfBenchm benchm = condBenchmarksL . traversed . filtered ((== benchm) . fst) . _2 . biplate

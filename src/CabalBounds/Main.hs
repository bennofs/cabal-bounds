{-# Language StandaloneDeriving #-}

module CabalBounds.Main
   ( cabalBounds
   ) where

import Distribution.PackageDescription (GenericPackageDescription)
import Distribution.PackageDescription.Parse (parsePackageDescription, ParseResult(..))
import Distribution.PackageDescription.PrettyPrint (showGenericPackageDescription)
import Distribution.Simple.Configure (ConfigStateFileErrorType(..), tryGetConfigStateFile)
import Distribution.Simple.LocalBuildInfo (LocalBuildInfo)
import qualified CabalBounds.Args as A
import qualified CabalBounds.Bound as B
import qualified CabalBounds.Sections as S
import qualified CabalBounds.Dependencies as DP
import qualified CabalBounds.Drop as D
import qualified CabalBounds.Update as U
import qualified System.IO.Strict as SIO
import Control.Applicative ((<$>))

type Error = String

cabalBounds :: A.Args -> IO (Maybe Error)
cabalBounds args@A.Drop {} = do
   pkgDescrp <- packageDescription $ A.cabalFile args
   case pkgDescrp of
        Left  error      -> return . Just $ error
        Right pkgDescrp_ -> do
           let pkgDescrp' = D.drop (B.boundOfDrop args) (S.sections args) (DP.dependencies args) pkgDescrp_
           writeFile (A.outputFile args) (showGenericPackageDescription pkgDescrp')
           return Nothing

cabalBounds args@A.Update {} = do
   pkgDescrp <- packageDescription $ A.cabalFile args
   buildInfo <- localBuildInfo $ A.setupConfigFile args
   case (pkgDescrp, buildInfo) of
        (Left error, _) -> return . Just $ error
        (_, Left error) -> return . Just $ error
        (Right pkgDescrp_, Right buildInfo_) -> do
           let pkgDescrp' = U.update (B.boundOfUpdate args) (S.sections args) (DP.dependencies args) pkgDescrp_ buildInfo_
           writeFile (A.outputFile args) (showGenericPackageDescription pkgDescrp')
           return Nothing


packageDescription :: FilePath -> IO (Either Error GenericPackageDescription)
packageDescription file = do
   contents <- SIO.readFile file
   case parsePackageDescription contents of
        ParseFailed error   -> return . Left  $ show error
        ParseOk _ pkgDescrp -> return . Right $ pkgDescrp


localBuildInfo :: FilePath -> IO (Either Error LocalBuildInfo)
localBuildInfo file =
   either (Left . show) Right <$> tryGetConfigStateFile file

deriving instance Show ConfigStateFileErrorType

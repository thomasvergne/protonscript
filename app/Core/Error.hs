{-# OPTIONS_GHC -Wno-orphans #-}
module Core.Error where
  import Error.Diagnose.Compat.Parsec
    ( errorDiagnosticFromParseError, HasHints(..) )
  import Error.Diagnose (addFile, printDiagnostic, stderr, defaultStyle, err, Position (Position), Marker (This), def, stdout, addReport)
  import Data.Void (Void)
  import Text.Parsec
    ( SourcePos, sourceColumn, sourceLine, sourceName, ParseError )

  instance HasHints Void String where
    hints _ = mempty

  printError :: (String, Maybe String, (SourcePos, SourcePos)) -> String -> IO ()
  printError (error', msg, (p1, p2)) step = do
    let p1' = (sourceLine p1, sourceColumn p1)
    let p2' = (sourceLine p2, sourceColumn p2)
    let file' = sourceName p1
    x' <- readFile file'
    let pos' = Position p1' p2' $ sourceName p1
    let beautifulExample = err
          Nothing
          error'
          [ (pos', This step) ]
          (maybe [] ((:[])) msg)

    -- Create the diagnostic 
    let diagnostic  = addFile def file' x'
    let diagnostic' = addReport diagnostic beautifulExample

    -- Print with unicode characters, colors and the default style
    printDiagnostic stdout True True 4 defaultStyle diagnostic'

  printParseError :: ParseError -> String -> IO ()
  printParseError err' file = do
    x <- readFile file
    let diag  = errorDiagnosticFromParseError Nothing "Parse error on input" Nothing err'
        diag' = addFile diag file x
      in printDiagnostic stderr True True 4 defaultStyle diag'
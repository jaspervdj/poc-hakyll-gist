{-# LANGUAGE OverloadedStrings #-}
module Main (main) where

import           Data.Text               (Text)
import qualified Data.Text.Lazy          as TL
import qualified Data.Text.Lazy.Encoding as TL
import           Hakyll
import qualified Text.Pandoc             as Pandoc

compileGist :: Text -> Compiler (Item String)
compileGist language = do
    source <- TL.toStrict . TL.decodeUtf8 . itemBody <$> getResourceLBS
    writePandoc <$> makeItem (toPandoc source)
 where
    classes = ["numberLines", "lineAnchors", language]
    toPandoc source = Pandoc.Pandoc mempty
        [Pandoc.CodeBlock (mempty, classes, []) source]

main :: IO ()
main = hakyll $ do

    match "*.c" $ do
        route $ setExtension "html"
        compile $ compileGist "c" >>=
            loadAndApplyTemplate "gist.html" defaultContext

    match "style.css" $ do
        route idRoute
        compile compressCssCompiler

    match "gist.html" $ compile templateCompiler

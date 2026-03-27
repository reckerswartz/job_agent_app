const path = require("path")
const webpack = require("webpack")
const MiniCssExtractPlugin = require("mini-css-extract-plugin")
const CssMinimizerPlugin = require("css-minimizer-webpack-plugin")

const isProduction = process.env.NODE_ENV === "production"

module.exports = {
  mode: isProduction ? "production" : "development",
  devtool: isProduction ? "source-map" : "eval-cheap-module-source-map",
  entry: {
    application: [
      "./app/javascript/application.js",
      "./app/assets/stylesheets/application.scss"
    ]
  },
  output: {
    filename: "[name].js",
    sourceMapFilename: "[file].map",
    chunkFormat: "module",
    path: path.resolve(__dirname, "app/assets/builds"),
    clean: true,
  },
  module: {
    rules: [
      {
        test: /\.scss$/,
        use: [
          MiniCssExtractPlugin.loader,
          {
            loader: "css-loader",
            options: { sourceMap: !isProduction }
          },
          {
            loader: "sass-loader",
            options: {
              sourceMap: !isProduction,
              sassOptions: {
                quietDeps: true,
                silenceDeprecations: ["import"],
                loadPaths: [path.resolve(__dirname, "node_modules")]
              }
            }
          }
        ]
      }
    ]
  },
  plugins: [
    new webpack.optimize.LimitChunkCountPlugin({ maxChunks: 1 }),
    new MiniCssExtractPlugin({ filename: "[name].css" })
  ],
  optimization: {
    minimizer: [
      "...",
      new CssMinimizerPlugin()
    ]
  },
  stats: {
    errorDetails: true
  }
}

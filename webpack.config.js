"use strict";

const path = require('path');
const Webpack = require('webpack');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

const extractSass = new ExtractTextPlugin("app.css");

module.exports = {
  entry: ['./web/static/js/app.js', './web/static/css/app.css'],
  output: {
    filename: 'app.js',
    path: path.resolve(__dirname, 'priv/static/js')
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          query: {
            presets: ['react', 'es2015']
          }
        }
      },
      {
        test: /\.css$/,
        loader: 'css-loader'
      },
      {
        test: /\.scss$/,
        loader: extractSass.extract({
          loader: [{ loader: "css-loader" }, { loader: "sass-loader" }],
          fallbackLoader: "style-loader"
        })
      },
      { test: /\.(png|woff|woff2|eot|ttf|svg)$/,
        use: ['url-loader'] }
    ]
  },
  resolve: {
    extensions: [".js", ".css", ".scss"]
  },
  plugins: [
    extractSass,
    new CopyWebpackPlugin([
      { from: path.resolve(__dirname, 'priv/static/js/app.css'),
        to: path.resolve(__dirname, 'priv/static/css') }
      ]),
    new Webpack.ProvidePlugin({
      jQuery: 'jquery',
      $: 'jquery',
      jquery: 'jquery'
    })
  ]
};

const path = require('path');
const glob = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = (env, options) => ({
  optimization: {
    minimizer: [
      new UglifyJsPlugin({ cache: true, parallel: true, sourceMap: false }),
      new OptimizeCSSAssetsPlugin({})
    ]
  },
  entry: {
    './js/app.js': glob.sync('./vendor/**/*.js').concat(['./js/app.js'])
  },
  output: {
    filename: 'app.js',
    path: path.resolve(__dirname, '../priv/static/js')
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      },
      {
        test: /\.(sa|sc|c)ss$/,
        use: [
          {
            loader: MiniCssExtractPlugin.loader
          },
          'css-loader',
          'postcss-loader',
          'sass-loader'
        ]
        // use: MiniCssExtractPlugin.extract({
        //   use: [{
        //     loader: "css-loader"
        //   }, {
        //     loader: "postcss-loader"
        //   }, {
        //     loader: "sass-loader",
        //     options: {
        //       precision: 8,
        //       includePaths: [
        //         'node_modules/bootstrap/scss',
        //         'node_modules/@fortawesome/fontawesome-free/scss'
        //       ]
        //     }
        //   }],
        //   fallback: 'style-loader'
        // })
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({ filename: '../css/app.scss' }),
    new CopyWebpackPlugin([{ from: 'static/', to: '../' }])
  ]
});

var path = require('path');
var webpack = require('webpack');

module.exports = {
  entry: './app/App',
  devtool: 'eval-inline-source-map',
  debug: true,
  output: {
    path: path.join(__dirname, 'public'),
    filename: 'app.js',
  },
  resolveLoader: {
    modulesDirectories: ['node_modules']
  },
  resolve: {
    root: path.resolve('./app'),
    extensions: ['', '.js', '.coffee', '.hbs']
  },
  module: {
    loaders: [
      {
        test: /\.hbs$/,
        loader: 'handlebars-loader',
        query: {
          helperDirs: [ path.resolve('./app/helpers') ]
        }
      },
      {
        test: /\.coffee$/,
        loader: 'coffee-loader'
      }
    ]
  },
  node: {
    fs: 'empty'
  }
};

/**
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  View
} from 'react-native';

import ReactNativeTab from './app/ReactNativeTab';

export default class SwiftReactNativeHybrid extends Component {

  // Use this to intialize global state that all tabs will use,
  // e.g. a Redux store and Provider
  render() {
    return (
      <View/>
    );
  }
}

AppRegistry.registerComponent('SwiftReactNativeHybrid', () => SwiftReactNativeHybrid);
AppRegistry.registerComponent('ReactNativeTab', () => ReactNativeTab);

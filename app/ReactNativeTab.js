/**
 * @flow
 */

import React, { Component } from 'react';
import {
  Button,
  NativeModules,
  StyleSheet,
  Text,
  TextInput,
  View
} from 'react-native';

export default class ReactNativeTab extends Component {
    constructor(props) {
    super(props);
    this.state = { text: 'Enter text to send to Swift' };
  }

  render() {
    return (
      <View style={styles.container}>
        <View style={styles.mainContent}>
          <Text style={styles.welcome}>
            Welcome to React Native!
          </Text>
          <Text style={styles.instructions}>
            To get started, edit ReactNativeTab.js
          </Text>
          <Text style={styles.instructions}>
            Press Cmd+R to reload,{'\n'}
            Cmd+D or shake for dev menu
          </Text>
          <TextInput
            style={{height: 44, borderColor: 'gray', borderWidth: 1}}
            onChangeText={(text) => this.setState({text})}
            value={this.state.text}
          />
          <Button
            onPress={ () => this.callIntoSwift(this.state.text) }
            title="Call Swift with Text"
            color="#841584"
          />
        </View>
        <View style={styles.tabContentBottomSpacer}/>
      </View>
    );
  }

  callIntoSwift(greeting: string) {
    NativeModules.NativeModuleCallSwift.helloSwift(greeting);
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  mainContent: {
    flex: 1,
    justifyContent: 'center',
    backgroundColor: '#F5FCFF',
  },
  tabContentBottomSpacer: {
    height: 49, //the height of the tab bar. Note the tab bar is translucent and this color will shine through
    backgroundColor: '#FFFFFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

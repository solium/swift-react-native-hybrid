/**
 * @flow
 */

import React, { Component } from 'react';
import {
  Button,
  NativeModules,
  NativeEventEmitter,
  StyleSheet,
  Text,
  TextInput,
  View
} from 'react-native';

import EmitterSubscription from 'EmitterSubscription';

type StateType = {
  textField: string;
  swiftCounterValue: number;
  swiftButtonCurrentlyEnabled: boolean;
};

export default class ReactNativeTab extends Component {
  state: StateType;

  constructor(props: Object) {
    super(props);
    this.state = {
      textField: 'Enter text to send to Swift',
      swiftCounterValue: 0,
      swiftButtonCurrentlyEnabled: true,
     };
  }

  counterChangedEventEmitter: ?NativeEventEmitter = null;
  counterChangedEventSubscriber: EmitterSubscription = null;

  componentWillMount(): void {
    this.setupSwiftCounterChangedEventListener();
  }

  componentWillUnmount(): void {
    this.counterChangedEventSubscriber.remove();
  }

  // Type 1: Calling a Swift function from JavaScript
  callIntoSwift(greeting: string) {
    NativeModules.NativeModuleCallSwift.helloSwift(greeting);
  }

  // Type 2: Calling a Swift function with a callback
  toggleSwiftButtonEnabledState() {
    NativeModules.NativeModuleJavaScriptCallback.toggleSwiftButtonEnabled(
        (newStateDict) => {
          this.setState({ swiftButtonCurrentlyEnabled: newStateDict.swiftButtonEnabled });
        }
      );
  }

  // Type 3: Broadcasting data from Swift and listening in JavaScript
  setupSwiftCounterChangedEventListener() {
    this.counterChangedEventEmitter = new NativeEventEmitter(NativeModules.NativeModuleBroadcastToJavaScript);
    this.counterChangedEventSubscriber = this.counterChangedEventEmitter.addListener(
      "SwiftCounterChanged",
      (countEventInfo) => {
        this.setState({ swiftCounterValue: countEventInfo.count });
      }
    );
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
            onChangeText={(textField) => this.setState({textField})}
            value={this.state.textField}
          />
          <Button
            onPress={ () => this.callIntoSwift(this.state.textField) }
            title="1. Call Swift with Text"
            color="#007aff"
          />
          <Text style={{textAlign: 'center', marginTop: 30}}>
            Swift button currently enabled: {this.state.swiftButtonCurrentlyEnabled.toString()}
          </Text>
          <Button
            onPress={ () => this.toggleSwiftButtonEnabledState() }
            title="2. Toggle Swift Increment Button Enabled"
            color="#007aff"
          />
          <Text style={{textAlign: 'center', marginTop: 30}}>
            3. Swift counter value: {this.state.swiftCounterValue.toString()}
          </Text>
        </View>
        <View style={styles.tabContentBottomSpacer}/>
      </View>
    );
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
    marginBottom: 30,
  },
});

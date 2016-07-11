
import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  TextInput,
  NativeAppEventEmitter,
  Navigator
} from 'react-native';

var EMSDKBridge = require('react-native').NativeModules.EMSDKBridge;

import ChatList from "./ChatList.js";

export default class Login extends Component {
  componentDidMount = ()=>{
  };


  state = {

    sendMess:"",
    Mess:"未收到消息",
    to:"",

    name:"test1",
    password:"1234",

    register:false,
  };

  render() {

    return (<View style={styles.container}>
      <Text style={styles.welcome} >
        {this.state.register ? "注册":"登录" }
      </Text>
      <TextInput style={{height: 40, borderColor: 'gray', borderWidth: 1, marginLeft:50, marginRight:50}}
                 placeholder="name"
                 onChangeText={(text) => this.setState({name:text})}
                 value={this.state.name} />
      <TextInput style={{height: 40, borderColor: 'gray', borderWidth: 1, marginLeft:50, marginRight:50,marginTop:30}}
                 placeholder="password"
                 onChangeText={(text) => this.setState({password:text})}
                 value={this.state.password} />
      <Text style={styles.welcome} onPress={
        ()=>{
        if(this.state.register){
            EMSDKBridge.registerWithUsername(
            this.state.name,
            this.state.password,
            (error, events) => {
              if (error) {
                console.error(error);
              } else {
                if(events[0] == "1"){
                  alert("注册成功!");
                }else{
                  alert(events[0]);
                }
              }
            });
        }else{
             EMSDKBridge.loginWithUsername(
             this.state.name,
             this.state.password,
             false,
             (error, events) => {
              if (error) {
                console.error(error);
              } else {
                if(events[0] == "1"){
                  const { navigator } = this.props;
                  //为什么这里可以取得 props.navigator?请看上文:
                  //<Component {...route.params} navigator={navigator} />
                  //这里传递了navigator作为props
                  if(navigator) {
                      navigator.push({
                          name: 'ChatList',
                          component: ChatList,
                          param:{
                          sceneAnimation: Navigator.SceneConfigs.PushFromRight,
                          bb:"chatlist"
                          }
                      })
                  }
                }else{
                    alert(events[0]);
                }
              }
            });
        }}
        }>
        {this.state.register ? "注册":"登录" }
      </Text>
      {/*
       <Text style={styles.welcome} onPress={
       ()=>{
       EMSDKBridge.getConversationWithId("test2",()=>{})
       }
       }>
       getMess
       </Text>
       */}

      <Text style={styles.welcome} onPress={
        ()=>{
        this.setState({register:!this.state.register})
        }
        }>
        {!this.state.register ? "我要注册":"我要登录" }
      </Text>


    </View>);
  }


}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
    marginTop:30
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
    marginTop:30
  },
});
/**
 * Created by AMI on 16/7/9.
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  TextInput,
  NativeAppEventEmitter,
  Navigator,
  ScrollView
} from 'react-native';

var EMSDKBridge = require('react-native').NativeModules.EMSDKBridge;

export default class ChatList extends Component {
  subscription ;
  componentDidMount = ()=>{
    this.subscription = NativeAppEventEmitter.addListener(
      'EventReminder',
      (reminder) => {
        this.setState({MessArray: [...this.state.MessArray, reminder.name]});
      }
    );
  };


  state = {
    sendMess:"",
    Mess:"未收到消息",
    to:"test1",
    MessArray:[],
  };


  back = ()=>{
      const { navigator } = this.props;
      if(navigator) {
        this.subscription.remove();
        navigator.pop();
      }
    };
 _sc : ScrollView;
  render() {

    return (<View style={styles.container}>
      <ScrollView style={{flex:1}}
                  ref={(scrollView)=>{this._sc = scrollView;}}
                  showsVerticalScrollIndicator={false}
                  showsHorizontalScrollIndicator={false}>
        {this.state.MessArray.map((item, i, items)=>{
          return <Text style={styles.instructions} key={"MessArray"+i}>{`第${i}条内容:${item}`}</Text>
        })}
      </ScrollView>
      <View style={{flex:1}}>
        <Text style={{height:20 }} >
          输入和谁对话默认和test1对话
        </Text>
        <TextInput style={{height: 40, borderColor: 'gray', borderWidth: 1, margin:10}}
                   placeholder="对方name"
                   onChangeText={(text) => this.setState({to:text})}
                   value={this.state.to} />
        <Text style={styles.instructions} >
          输入发送的文字内容!
        </Text>
        <TextInput style={{height: 40, borderColor: 'gray', borderWidth: 1, margin:10}}
                   placeholder="发送的文字内容!"
                   onChangeText={(text) => this.setState({sendMess:text})}
                   value={this.state.sendMess}>
        </TextInput>

        <Text style={styles.instructions} onPress={
        ()=>{
        EMSDKBridge.sendWithMessage(
        this.state.sendMess,
        this.state.to,
        (error, events) => {
              if (error) {
                console.error(error);

              } else {
                if(events[0] == "1"){
                  //alert("发送成功!");
                  let ll = this.state.MessArray.length;
                  if(ll>5){
                 this._sc.scrollTo({x: 0, y: 30*(ll-4), animation: true});
                  }
                }else{
                  alert(events[0]);
                }
              }
            } );
        }
        }>
          发送文本框内消息
        </Text>

        <Text style={[styles.instructions, {marginTop:30}]} onPress={
        ()=>{this.logout(); }
        }>
          退出当前账号!
        </Text>
        <Text style={[styles.instructions, {marginTop:20}]} onPress={
        ()=>{
        this.logout();
        const { navigator } = this.props;
        if(navigator) {navigator.pop();}
        }}>
          返回上一页
        </Text>
      </View>

    </View>);
  }
  logout=()=>{
          EMSDKBridge.logout((error, events) => {
          if (error) {
            console.error(error);
          } else {
          if(events[0] == "1"){
          //alert("成功推出!");
          this.back();
        }else{
          alert(events[0]);
        }
        }
        });
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
    marginTop:10
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
    marginTop:10
  },
});
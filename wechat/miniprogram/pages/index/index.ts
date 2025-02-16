// index.ts
// 获取应用实例
const app = getApp<IAppOption>()
const defaultAvatarUrl = 'https://mmbiz.qpic.cn/mmbiz/icTdbqWNOwNRna42FI242Lcia07jQodd2FJGIYQfG0LAJGFxM4FbnQP6yfMxBgJ0F3YRqJCJ1aPAK2dQagdusBZg/0'

Component({
  data: {
    motto: 'Hello World',
    userInfo: {
      avatarUrl: defaultAvatarUrl,
      nickName: '',
    },
    hasUserInfo: false,
    canIUseGetUserProfile: wx.canIUse('getUserProfile'),
    canIUseNicknameComp: wx.canIUse('input.type.nickname'),
    messages: [] as { id: number; role: string; content: string }[], // 聊天记录
    inputText: '', // 用户输入
    messageId: 0, // 消息 ID
  },
  methods: {
    // 事件处理函数
    bindViewTap() {
      wx.navigateTo({
        url: '../logs/logs',
      })
    },
    onChooseAvatar(e: any) {
      const { avatarUrl } = e.detail
      const { nickName } = this.data.userInfo
      this.setData({
        "userInfo.avatarUrl": avatarUrl,
        hasUserInfo: nickName && avatarUrl && avatarUrl !== defaultAvatarUrl,
      })
    },
    onInputChange(e: any) {
      const nickName = e.detail.value
      const { avatarUrl } = this.data.userInfo
      this.setData({
        "userInfo.nickName": nickName,
        hasUserInfo: nickName && avatarUrl && avatarUrl !== defaultAvatarUrl,
      })
    },
    getUserProfile() {
      // 推荐使用wx.getUserProfile获取用户信息，开发者每次通过该接口获取用户个人信息均需用户确认，开发者妥善保管用户快速填写的头像昵称，避免重复弹窗
      wx.getUserProfile({
        desc: '展示用户信息', // 声明获取用户个人信息后的用途，后续会展示在弹窗中，请谨慎填写
        success: (res) => {
          console.log(res)
          this.setData({
            userInfo: res.userInfo,
            hasUserInfo: true
          })
        }
      })
    },
    // 用户输入
    onInput(e: any) {
      this.setData({
        inputText: e.detail.value,
      });
    },
    // 发送消息
    sendMessage() {
      const { inputText, messages, messageId } = this.data;
      if (!inputText.trim()) return;

      // 添加用户消息
      const userMessage = {
        id: messageId,
        role: 'user',
        content: inputText,
      };
      this.setData({
        messages: [...messages, userMessage],
        inputText: '',
        messageId: messageId + 1,
      });

      // 调用后端 API 获取算命结果
      wx.request({
        url: 'http://127.0.0.1:8000/predict', // 修改为你的后端地址
        method: 'POST',
        data: { question: inputText },
        success: (res: any) => {
          const assistantMessage = {
            id: messageId + 1,
            role: 'assistant',
            content: res.data.prediction,
          };
          this.setData({
            messages: [...this.data.messages, assistantMessage],
            messageId: messageId + 2,
          });
        },
        fail: (err: any) => {
          console.error('请求失败:', err);
          wx.showToast({
            title: '请求失败，请重试',
            icon: 'none',
          });
        },
      });
    },
  },
})

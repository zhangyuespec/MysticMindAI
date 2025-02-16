import SwiftUI

struct ContentView: View {
    @State private var question: String = ""
    @State private var prediction: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            // 标题
            Text("赛博算命")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 40)

            // 输入框
            TextField("请输入你的问题", text: $question)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)

            // 获取预测按钮
            Button(action: fetchPrediction) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("获取预测")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .disabled(isLoading)
            .padding(.horizontal)

            // 预测结果
            ScrollView {
                Text(prediction)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
    }

    func fetchPrediction() {
        guard !question.isEmpty else {
            prediction = "请输入问题"
            return
        }

        isLoading = true
        prediction = ""

        guard let url = URL(string: "http://127.0.0.1:8000/predict") else {
            print("无效的 URL")
            isLoading = false
            return
        }

        let body: [String: Any] = ["question": question]
        guard let finalData = try? JSONSerialization.data(withJSONObject: body) else {
            print("无法序列化 JSON 数据")
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = finalData

        print("正在发送请求...")
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    print("请求失败: \(error.localizedDescription)")
                    prediction = "请求失败，请重试"
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("状态码: \(httpResponse.statusCode)")
                }

                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        prediction = json?["prediction"] as? String ?? "无法获取预测"
                    } catch {
                        print("无法解析 JSON 数据: \(error.localizedDescription)")
                        prediction = "解析数据失败"
                    }
                }
            }
        }.resume()
    }
}

struct PredictionResponse: Codable {
    let prediction: String
}

#Preview {
    ContentView()
}

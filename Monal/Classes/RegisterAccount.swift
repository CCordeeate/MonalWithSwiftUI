//
//  RegisterAccount.swift
//  Monal
//
//  Created by CC on 22.04.22.
//  Copyright © 2022 Monal.im. All rights reserved.
//

import SwiftUI
import SafariServices
import WebKit
 
struct WebView: UIViewRepresentable {
 
    var url: URL
 
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct RegisterAccount: View {
    static private let credFaultyPattern = ".*@.*"

    @Binding private var selectedServerIndex : Int
    @Binding private var providedServer : String

    @State private var username: String = ""
    @State private var password: String = ""
        
    @State private var showAlert = false
    @State private var showWebView = false
    
    @State private var alertPrompt = AlertPrompt(dismissLabel: Text("Close"))

    private var actualServer: String
    private var actualTermsUrl: String
    private var showTermsUrl = false

    private var credentialsEnteredAlert: Bool {
        alertPrompt.title = Text("No Empty Values!")
        alertPrompt.message = Text("Please make sure you have entered a username, password.")
        
        return credentialsEntered
    }

    private var credentialsFaultyAlert: Bool {
        alertPrompt.title = Text("Invalid Username!")
        alertPrompt.message = Text("The username does not need to have an @ symbol. Please try again.")

        return credentialsFaulty
    }

    private var credentialsExistAlert: Bool {
        alertPrompt.title = Text("Duplicate Account!")
        alertPrompt.message = Text("This account already exists on this instance.")
        
        return credentialsExist
    }

    private var credentialsEntered: Bool {
        return !username.isEmpty && !password.isEmpty
    }

    private var credentialsFaulty: Bool {
        return username.range(of: RegisterAccount.credFaultyPattern, options: .regularExpression) != nil
    }

    private var credentialsExist: Bool {
        // TODO: To be replaced by actual test if user already exist on the monal instance
        return false
    }

    private var buttonColor: Color {
            return !credentialsEntered || credentialsFaulty ? .gray : .blue
    }
    
    init(_ selectedServerIndex: Binding<Int>, _ providedServer: Binding<String>) {
        self._selectedServerIndex = selectedServerIndex
        self._providedServer = providedServer
        actualServer = providedServer.wrappedValue
        actualTermsUrl = "None"
        
        if (actualServer == "") {
            actualServer = "None"
            actualTermsUrl = "None"
            
            if let temp = RegisterAccountSelectServer.XMPPServer[selectedServerIndex.wrappedValue]["XMPPServer"] {
                if (temp != "") {
                    actualServer = temp
 
                    let temp = RegisterAccountSelectServer.XMPPServer[selectedServerIndex.wrappedValue]["TermsSite_\(Locale.current.languageCode ?? "default")"] ?? RegisterAccountSelectServer.XMPPServer[selectedServerIndex.wrappedValue]["TermsSite_default"] ?? ""
                        if (temp != "") {
                            actualTermsUrl = temp
                            showTermsUrl = true
                        }
                }
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Choose a username and a password to register an account on selected server \(actualServer).")
                   .padding()
                
                Form {
                    Text("Register for \(actualServer)")
                    TextField("Username", text: Binding(get: { self.username }, set: { string in self.username = string.lowercased() }))
                        .disableAutocorrection(true)
                    SecureField("Password", text: $password)
                    
                    Button(action: {
                        showAlert = !credentialsEnteredAlert || credentialsFaultyAlert || credentialsExistAlert
                        
                        if !showAlert {
                            // TODO: Code/Action for registration and jump to whatever view after successful registration
                        }
                    }){
                        Text("Register")
                            .frame(maxWidth: .infinity)
                            .padding(9.0)
                            .background(Color(red: 0.897, green: 0.878, blue: 0.878))
                            .foregroundColor(buttonColor)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .alert(isPresented: $showAlert) {
                        Alert(title: alertPrompt.title, message: alertPrompt.message, dismissButton: .default(alertPrompt.dismissLabel))
                    }
                    
                    Button (action: {
                        showWebView.toggle()
                    }){
                        Text("Terms of use")
                    }
                    .disabled(!showTermsUrl)
                    .opacity(showTermsUrl ? 1 : 0)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10.0)
                    .padding(.bottom, 9.0)
                    .sheet(isPresented: $showWebView) {
                        Text("Terms of\n\(actualServer)")
                            .font(.largeTitle.weight(.bold))
                            .multilineTextAlignment(.center)
                        WebView(url: URL(string: actualTermsUrl)!)
                        Button (action: {
                            showWebView.toggle()
                        }){
                            Text("Close")
                                .padding(9.0)
                                .background(Color(red: 0.897, green: 0.878, blue: 0.878))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .padding(.top, 10.0)
                        .padding(.bottom, 9.0)
                    }
                }
                .frame(minHeight: 310)
                .textFieldStyle(.roundedBorder)
                
            }
        }
        
        .navigationTitle("Register Account")
    }
}

struct RegisterAccount_Previews: PreviewProvider {
    @State private var providedServer: String = ""
    @State private var selectedServerIndex = 0

    static var previews: some View {
        RegisterAccount(RegisterAccount_Previews().$selectedServerIndex, RegisterAccount_Previews().$providedServer)
    }
}

//
//  DonateView.swift
//  
//
//  Created by Bill Haku on 2021/11/4.
//  Copyright © 2021 BillHaku. All rights reserved.
//

import SwiftUI

struct DonateView: View {
    var body: some View {
        VStack {
            Text("Thanks for your donate!")
                .padding()
            HStack {
                Image("WechatPay")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
                Image("UnionPay")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
                Image("AliPay")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
            }
            .frame(minWidth: 566)
            .padding()
        }
    }
}

struct DonateView_Previews: PreviewProvider {
    static var previews: some View {
        DonateView()
    }
}

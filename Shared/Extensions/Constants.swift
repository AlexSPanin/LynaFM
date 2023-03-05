//
//  Constants.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import SwiftUI

//MARK: - параметры экрана и версии программы
let WIDTH = UIScreen.main.bounds.width
let HEIGHT = UIScreen.main.bounds.height
let version = Bundle.main.appVersion + "." + Bundle.main.appBuild
let scaleWidth = WIDTH / 320
let scaleHeight = HEIGHT / 568

let userDefaults = UserDefaults.standard
let fileManager = FileManager.default
let nameLogo = "Lyna_1024"
let languageType: TypeLanguage = .rus
let language = languageType.label

//MARK: - коофициент для пересчета элементов при малой ширине экрана
let isSmallWIDTH: Bool = WIDTH < 340
let isSmallHEIGHT: Bool = HEIGHT < 690
let scale = 0.9

//MARK: - размеры элементов и отступов

let hPadding: CGFloat = 15 * scaleWidth
let vPadding: CGFloat = 15 * scaleHeight
let screen: CGFloat = WIDTH * 0.95
let corner: CGFloat = 5 * scaleWidth
let imageL: CGFloat = WIDTH * 0.3
let imageN: CGFloat = WIDTH * 0.2
let imageS: CGFloat = WIDTH * 0.1
let picker: CGFloat = WIDTH * 0.03
let pickerL: CGFloat = WIDTH * 0.05

//MARK: - цвета для приложения

let mainColor: Color = .gray
let mainLigth: Color = mainColor.opacity(0.1)
let mainRigth: Color = .cyan.opacity(0.8)
let mainBack: Color = .orange.opacity(0.8)
let mainDark: Color = mainColor.opacity(0.6)


//MARK: - шрифты для приложения
let fontSx = Font.caption
let fontSm = Font.footnote
let fontS = Font.callout
let fontN = Font.body
let fontL = Font.headline
let fontLX = Font.title
let fontLXX = Font.largeTitle

let fontBold28 = Font.system(size: scaleWidth * 28, weight: .bold)
let fontBold24 = Font.system(size: scaleWidth * 24, weight: .bold)
let fontBold20 = Font.system(size: scaleWidth * 20, weight: .bold)
let fontBold18 = Font.system(size: scaleWidth * 18, weight: .bold)
let fontBold16 = Font.system(size: scaleWidth * 16, weight: .bold)
let fontBold14 = Font.system(size: scaleWidth * 14, weight: .bold)
let fontBold12 = Font.system(size: scaleWidth * 12, weight: .bold)

let fontMedium18 = Font.system(size: scaleWidth * 18, weight: .medium)
let fontMedium16 = Font.system(size: scaleWidth * 16, weight: .medium)
let fontMedium14 = Font.system(size: scaleWidth * 14, weight: .medium)
let fontMedium12 = Font.system(size: scaleWidth * 12, weight: .medium)
let fontMedium10 = Font.system(size: scaleWidth * 10, weight: .medium)

let fontRegular16 = Font.system(size: scaleWidth * 16, weight: .regular)
let fontRegular14 = Font.system(size: scaleWidth * 14, weight: .regular)
let fontRegular13 = Font.system(size: scaleWidth * 13, weight: .regular)
let fontRegular12 = Font.system(size: scaleWidth * 12, weight: .regular)
let fontRegular10 = Font.system(size: scaleWidth * 10, weight: .regular)
let fontRegular9 = Font.system(size: scaleWidth * 9, weight: .regular)
let fontRegular8 = Font.system(size: scaleWidth * 8, weight: .regular)

let fontLight24 = Font.system(size: scaleWidth * 24, weight: .light)
let fontLight16 = Font.system(size: scaleWidth * 16, weight: .light)
let fontLight14 = Font.system(size: scaleWidth * 14, weight: .light)
let fontLight12 = Font.system(size: scaleWidth * 12, weight: .light)
let fontLight10 = Font.system(size: scaleWidth * 10, weight: .light)
let fontLight9 = Font.system(size: scaleWidth * 9, weight: .light)
let fontLight8 = Font.system(size: scaleWidth * 8, weight: .light)








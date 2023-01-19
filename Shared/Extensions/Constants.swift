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

// коофициент для пересчета элементов при малой ширине экрана
let isSmallWIDTH: Bool = WIDTH < 340
let isSmallHEIGHT: Bool = HEIGHT < 690
let scaleFactor = 0.9

//MARK: - размеры элементов и отступов

let hPadding: CGFloat = 15 * scaleWidth
let vPadding: CGFloat = 15 * scaleHeight
let buttonCorner: CGFloat = 5 * scaleWidth

//MARK: - цвета для приложения


//MARK: - шрифты для приложения
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

let Documents_Directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]






//
//  Consent.swift
//  OCKSample
//
//  Created by Corey Baker on 11/11/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation

// swiftlint:disable line_length

let informedConsentHTML = """
    <!DOCTYPE html>
    <html lang="en" xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta name="viewport" content="width=400, user-scalable=no">
        <meta charset="utf-8" />
        <style type="text/css">
            ul, p, h1, h3 {
                text-align: left;
            }
        </style>
    </head>
    <body>
        <h1>Informed Consent</h1>
        <h2>Warning</h2>
        <ul>
            <li>Not all exercises are suitable for everyone and this or any other exercise program may result in injury. PLEASE ALWAYS consult your DOCTOR before beginning this or any other exercise program, especially if you have any chronic or recurring condition, and/or if you are pregnant, nursing, or elderly. This exercise program is NOT recommended if you experience chest pains or have uncontrolled blood pressure or other uncontrolled chronic diseases.</li>
            <li>By performing any of the exercises in this program, you assume ALL risks of injury from doing so. AI Lifting is NOT responsible or liable for any injury or loss you may sustain by participating in this exercise program..</li>
            <li>ALWAYS warm up before beginning any workout and NEVER exercise beyond the level at which you feel comfortable.</li>
            <li>PLEASE stop exercising immediately if you experience pain, soreness, fatigue, shortness of breath, dizziness, lightheadedness, blurred vision, headache, nausea, sickness, illness, dehydration, excessive sweating, or any other discomfort. If any of these symptoms persists after you stop exercising, please seek medical help immediately. </li>
        </ul>
        <p>By signing below, I acknowledge that I have read this consent carefully, that I understand all of its terms, and that I assume all responsiblity for my actions. I understand that my information will only be used and disclosed for the purposes described in the consent and I can withdraw from the app at any time.</p>
        <p>Please sign using your finger below.</p>
        <br>
    </body>
    </html>
    """

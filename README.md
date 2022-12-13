# AI Lift
![Swift](https://img.shields.io/badge/swift-5.7-brightgreen.svg) ![Xcode 14.0+](https://img.shields.io/badge/xcode-14.0%2B-blue.svg) ![iOS 16.0+](https://img.shields.io/badge/iOS-16.0%2B-blue.svg) ![watchOS 9.0+](https://img.shields.io/badge/watchOS-9.0%2B-blue.svg) ![CareKit 2.1+](https://img.shields.io/badge/CareKit-2.1%2B-red.svg) ![ci](https://github.com/netreconlab/CareKitSample-ParseCareKit/workflows/ci/badge.svg?branch=main)

## Description
  AI Lift is an application designed to give user's options when it comes to their workouts. Traditional workout programs are carbon copied from person to person, but do not factor in important factors like workout history and current recovery levels. AI Lift pairs user reported data and automatically gathered HealthKit data to dynamically adjust a user's workout program. Information such as sleep quality, current stress levels, and other biometric data are used to automatically adjust how much exercise volume the user is doing during a workout. 
  
  One significant metric that is measured is heart rate variability (HRV). HRV is the difference in time between the beats of your heart. This is an easy way to measure the autonomic nervous system which plays a large role in how ready one is to get back into the gym. HRV can also give insights into how physically fit one is which can help determine the user's experience level. On average, a higher HRV measurement is better, but it is important to note that this value varies drastically from person to person.
  
### Below is a graph of HRV ranges based off of age.
![HRV Chart](https://www.whoop.com/wp-content/uploads/2020/01/heart-rate-variability-chart-ms-by-age-1024x928.png)
###### Source: Whoop.com

## Demo Video
ADD THIS

## Designed for the following users
AI Lift is designed for anyone looking to improve their overall physical strength levels without having to worry about overdoing or underdoing their workouts. All experience levels are welcome.

## Application Demo

INSERT PICTURES

### Developed By:
- [Colin Carver](https://github.com/ColinCarver10) - `University of Kentucky`, `Computer Science`

ParseCareKit synchronizes the following entities to Parse tables/classes using [Parse-Swift](https://github.com/parse-community/Parse-Swift):

- [x] OCKTask <-> Task
- [x] OCKHealthKitTask <-> HealthKitTask 
- [x] OCKOutcome <-> Outcome
- [x] OCKRevisionRecord.KnowledgeVector <-> Clock
- [x] OCKPatient <-> Patient
- [x] OCKCarePlan <-> CarePlan
- [x] OCKContact <-> Contact

**Use at your own risk. There is no promise that this is HIPAA compliant and we are not responsible for any mishandling of your data**

## Contributions / Features

## Final Checklist
- [x] Signup/Login screen tailored to app
- [x] Signup/Login with email address
- [x] Custom app logo
- [x] Custom styling
- [x] Add at least **5 new OCKTask/OCKHealthKitTasks** to your app
  - [x] Have a minimum of 7 OCKTask/OCKHealthKitTasks in your app
  - [x] 3/7 of OCKTasks should have different OCKSchedules than what's in the original app
- [x] Use at least 5/7 card below in your app
  - [x] InstructionsTaskView
  - [x] SimpleTaskView
  - [x] Checklist
  - [ ] Button Log
  - [ ] GridTaskView
  - [x] NumericProgressTaskView
  - [x] LabeledValueTaskView
- [x] Allow user to add new tasks including custom cards
- [x] Add the LinkView (SwiftUI) card to your app
- [x] Tailor the ResearchKit Onboarding to reflect your application
- [x] Add tailored check-in ResearchKit survey to your app
- [x] Add another Researchkit survey card
- [x] Replace current ContactView with Searchable contact view
- [x] Change the ProfileView to use a Form view
- [x] Add at least two OCKCarePlan's and tie them to their respective OCKTask's and OCContact's NEED TO DO THIS
- [x] Add a new tab called "Insights" to MainTabView
- [x] Use at least 2 custom cards ONLY HAVE DONE 1
- [x] Replace the current TipView with a class with CustomFeaturedContentView that subclasses OCKFeaturedContentView.



## Setup Your Parse Server

### Heroku
The easiest way to setup your server is using the [one-button-click](https://github.com/netreconlab/parse-hipaa#heroku) deployment method for [parse-hipaa](https://github.com/netreconlab/parse-hipaa).

### Docker
You can setup your [parse-hipaa](https://github.com/netreconlab/parse-hipaa) using Docker. Simply type the following to get parse-hipaa running with postgres locally:

1. Fork [parse-hipaa](https://github.com/netreconlab/parse-hipaa)
2. `cd parse-hipaa`
3.  `docker-compose up` - this will take a couple of minutes to setup as it needs to initialize postgres, but as soon as you see `parse-server running on port 1337.`, it's ready to go. See [here](https://github.com/netreconlab/parse-hipaa#getting-started) for details
4. If you would like to use mongo instead of postgres, in step 3, type `docker-compose -f docker-compose.mongo.yml up` instead of `docker-compose up`

## Fork this repo to get the modified OCKSample app

1. Fork [CareKitSample-ParseCareKit](https://github.com/netreconlab/ParseCareKit)
2. Open `OCKSample.xcodeproj` in Xcode
3. You may need to configure your "Team" and "Bundle Identifier" in "Signing and Capabilities"
4. Run the app and data will synchronize with parse-hipaa via http://localhost:1337/parse automatically
5. You can edit Parse server setup in the ParseCareKit.plist file under "Supporting Files" in the Xcode browser

## View your data in Parse Dashboard

### Heroku
The easiest way to setup your dashboard is using the [one-button-click](https://github.com/netreconlab/parse-hipaa-dashboard#heroku) deployment method for [parse-hipaa-dashboard](https://github.com/netreconlab/parse-hipaa-dashboard).

### Docker
Parse Dashboard is the easiest way to view your data in the Cloud (or local machine in this example) and comes with [parse-hipaa](https://github.com/netreconlab/parse-hipaa). To access:
1. Open your browser and go to http://localhost:4040/dashboard
2. Username: `parse`
3. Password: `1234`
4. Be sure to refresh your browser to see new changes synched from your CareKitSample app

Note that CareKit data is extremely sensitive and you are responsible for ensuring your parse-server meets HIPAA compliance.

## Transitioning the sample app to a production app
If you plan on using this app as a starting point for your produciton app. Once you have your parse-hipaa server in the Cloud behind ssl, you should open `ParseCareKit.plist` in Xcode and change the value for `Server` to point to your server(s) in the Cloud. You should also open `Info.plist` in Xcode and remove `App Transport Security Settings` and any key/value pairs under it as this was only in place to allow you to test the sample app to connect to a server setup on your local machine. iOS apps do not allow non-ssl connections in production, and even if you find a way to connect to non-ssl servers, it would not be HIPAA compliant.

### Extra scripts for optimized Cloud queries
You should run the extra scripts outlined on parse-hipaa [here](https://github.com/netreconlab/parse-hipaa#running-in-production-for-parsecarekit).

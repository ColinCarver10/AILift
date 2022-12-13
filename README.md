# AI Lift
![Swift](https://img.shields.io/badge/swift-5.7-brightgreen.svg) ![Xcode 14.0+](https://img.shields.io/badge/xcode-14.0%2B-blue.svg) ![iOS 16.0+](https://img.shields.io/badge/iOS-16.0%2B-blue.svg) ![watchOS 9.0+](https://img.shields.io/badge/watchOS-9.0%2B-blue.svg) ![CareKit 2.1+](https://img.shields.io/badge/CareKit-2.1%2B-red.svg) ![ci](https://github.com/netreconlab/CareKitSample-ParseCareKit/workflows/ci/badge.svg?branch=main)

## Description
  AI Lift is an application designed to give user's options when it comes to their workouts. Traditional workout programs are carbon copied from person to person, but do not factor in important factors like workout history and current recovery levels. AI Lift pairs user reported data and automatically gathered HealthKit data to dynamically adjust a user's workout program. Information such as sleep quality, current stress levels, and other biometric data are used to automatically adjust how much exercise volume the user is doing during a workout. 
  
  One significant metric that is measured is heart rate variability (HRV). HRV is the difference in time between the beats of your heart. This is an easy way to measure the autonomic nervous system which plays a large role in how ready one is to get back into the gym. HRV can also give insights into how physically fit one is which can help determine the user's experience level. On average, a higher HRV measurement is better, but it is important to note that this value varies drastically from person to person.
  
### Below is a graph of HRV ranges based off of age.
![HRV Chart](https://www.whoop.com/wp-content/uploads/2020/01/heart-rate-variability-chart-ms-by-age-1024x928.png)
###### Source: Whoop.com

## Demo Video
[![Demo Video](https://i9.ytimg.com/vi_webp/j3uzbS3TaPk/mq1.webp?sqp=CPSt4pwG-oaymwEmCMACELQB8quKqQMa8AEB-AH-CYAC0AWKAgwIABABGGUgVyhNMA8=&rs=AOn4CLAGSCQ4-tGOLUbrXOldBYewj7im8Q)](http://www.youtube.com/watch?v=j3uzbS3TaPk&ab)



## Designed for the following users
AI Lift is designed for anyone looking to improve their overall physical strength levels without having to worry about overdoing or underdoing their workouts. All experience levels are welcome.

## Application Demo
#### Startup & Onboarding Screens
<img width="175" alt="1" src="https://user-images.githubusercontent.com/112659162/207221043-51c4ded9-b01c-44f6-bd1e-8bedf654c209.png"><img width="175" alt="2" src="https://user-images.githubusercontent.com/112659162/207221216-fa347222-1679-4f11-9292-b28835ac7cc8.png"><img width="175" alt="3" src="https://user-images.githubusercontent.com/112659162/207221230-154ba3ad-53cd-4ed8-9425-087aac202af2.png">

#### Homescreen
<img width="175" alt="4" src="https://user-images.githubusercontent.com/112659162/207221259-4b5de7e9-0cee-43cb-bb06-92be3d83ed5c.png"><img width="175" alt="5" src="https://user-images.githubusercontent.com/112659162/207221266-3ee1b0b9-ecf3-42f6-a8f0-23aad41db7da.png"><img width="175" alt="6" src="https://user-images.githubusercontent.com/112659162/207221272-d6cbed7f-642a-400f-b509-f8e4f89aa335.png"><img width="175" alt="7" src="https://user-images.githubusercontent.com/112659162/207221278-c500a568-5ae2-4e99-8b88-44ab9d5ffc40.png">

#### Workout Setup Survey
<img width="175" alt="8" src="https://user-images.githubusercontent.com/112659162/207221306-65694fba-c822-4ce0-87cc-be0416cdb082.png"><img width="175" alt="9" src="https://user-images.githubusercontent.com/112659162/207221316-f52ad933-23fa-46ae-9d0f-6bf504f0a4d4.png">

#### Check In Survey
<img width="175" alt="10" src="https://user-images.githubusercontent.com/112659162/207221369-e772b37b-b0f1-4564-87c6-ae91ce8965a5.png">

#### Insights View
<img width="175" alt="11" src="https://user-images.githubusercontent.com/112659162/207221372-64ec0742-cb44-4bc8-b339-90451d76ef91.png">

#### Profile & Contact View
<img width="175" alt="12" src="https://user-images.githubusercontent.com/112659162/207221409-a96102cf-318e-4059-a2b2-1aad371d4d1f.png"><img width="175" alt="13" src="https://user-images.githubusercontent.com/112659162/207221416-33de707f-6260-42a8-99c5-bc0ffc2ec366.png">

#### Add Task View
<img width="175" alt="14" src="https://user-images.githubusercontent.com/112659162/207221431-0c9002ca-b67b-465b-9f93-524e8288b6a0.png">


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
- Added workout setup survey that asks the user to select workout type (bodybuilding, powerlifting, or weightlifting). Additionally, asks the users to input their current maxes for each major compound lift.
  - Custom Survey that uses ORKQuestionStep and ORKForm.
- CustomFeaturedContentView that links to a playlist of videos displaying how to do the exercises listed.
- Updated CheckIn survey to poll the user's sleep quality, recovery level, and current stress levels.
  - All survey's display information on completion.
- Heart Rate Variability OCKHealthKitTask displayed as NumericProgressTaskView
- OCKSimpleTaskViewController to display rest days.
- Check List that displays users warmup process.
- Custom Card that display workouts.
  - Allows user to input the weight they used for the lift.
  - User inputs RPE (Rate of Perceived Exertion) using stepper.
- Users can add tasks in profile view.
- Added insights tab to display charts for each task.
- LabeledValueTask to display total number of active calories burned during the day.
- SimpleTaskView to check if user has foam rolled or not.
- Added leg day, arm day, and rest day OCKCarePlans.

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
- [x] Add at least two OCKCarePlan's and tie them to their respective OCKTask's and OCContact's
- [x] Add a new tab called "Insights" to MainTabView
- [x] Use at least 2 custom cards
- [x] Replace the current TipView with a class with CustomFeaturedContentView that subclasses OCKFeaturedContentView.

## Wishlist features
- Update OCKStore based off type of workout selected.
    - Add other workout programs.
- Have profile view autoupdate. Currently does not automatically change to what is set by Workout Setup Survey.
- Create algorithm to display user friendly charts that depict recovery levels based off HRV, sleep, etc.
- Graph user inputted weight of each major lift over time. (Ideally graph it against projected max)
- Use sleep and HRV to update workout volume.
- Delete tasks.

## Challenges faced while developing
Overall this was quite a challenging project, but the freedom that we had in creating our own app allowed me to learn a lot. The challenges that I faced are listed:
- Extracting answers from custom surveys.
- Displaying data in charts for more complex data.
- Adding a custom workoutType property to the patient.
- Creating a high quality looking custom card.
- Automatically updating profileView to accept new change from WorkoutSetup survey.
- Initially understanding how storeManager worked and how to access it.

---
# Below is information for setting up the application.

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

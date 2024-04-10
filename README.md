<h1> Possible Finance Application - Analytics Capstone Project </h1>

This project aims to develop a Face ID Verification system, fraud detection, customer identity and bank account verification. The system utilizes image processing techniques from AWS rekognition to compare known identities with login attempts for authentication purposes.
<h2> Installation </h2>
<h4> To set up the project locally, follow these steps: </h4>
<li> Clone the repository to your local machine. </li>
<li> Install the required packages and libraries for image processing and data manipulation. </li>
<li> Download the known identity database from the provided Dropbox link programmatically. </li>

<h2> Code Walkthrough </h2>

1. App.R -> This is the application hosted from shinyapps.io which is used to verify our project by submitting a url with images.
2. ApplicationIntegration.R -> This integrates the all the blocks of functionalies and is triggered from the App.R
3. identityVerification.R , fraudsterIdentification, bankAcctVerification.R will work as the functionalities of the app and are triggered through integration file.   

![image](https://github.com/shriya1999/possiblefinance/assets/39586246/d8cd05d1-d1fd-4c5f-9a9a-982883b7d991)


# Configure the Application
To run the project, you first need to modify (`src/main/resources/*.properties`) based on your environment.
- To set (`reddit.properties`) correctly, you need to create your reddit app by following [this guide] (https://github.com/reddit/reddit/wiki/OAuth2)
- Also make sure to provide valid email configuration in (`email.properties`)

## Create Your Own Reddit App
1. First, go to your [Reddit Preferences page] (https://www.reddit.com/prefs/apps).
2. Click **Create an app** button:
  - **Name**: The name you have chosen for your app.
  - Choose the type of the app to be **web app**.
  - **Description**: Write the description of your app (optional).
  - **About url**: url of your application (optional).
  - **Redirect uri**: Very Important, the callback url to be redirected to after obtaining access token [http://localhost:8080/reddit-scheduler/redditLogin](#)
- [Simple AngularJS Front-End for a REST API](http://www.baeldung.com/angular-js-rest-api)

# heAR

## Inspiration

heAR was inspired by striving to create a seamless conversation experience for people who are hearing impaired. Unlike hearing aids or simple speech-to-text, heAR integrates the visual, audio, and emotional aspects of communication to provide an authentic interaction.

## What it does

heAR is an iOS application that transcribes conversations and conveys sentiments. The app is meant for users who are hearing impaired. A user would insert their phone into a VR headset and open the application when they are in conversation. Incoming sentences are immediately transcribed and displayed at the bottom of the screen. The sentiment of the sentence is also calculated, and visualized as a representative emoji near the speaker's head, in AR space.

## How we built it

**Swift 4** - For building iOS app

**ARKit** - For visualizing emojis in AR space

**Azure** - Provides Speech-to-Text, language detection, and sentiment analysis services

**Node.js/Express** - To build wrapper API for Azure services

**Google Cloud** - To deploy and host API service

**Sketch** - To create mockups

**Photoshop** - To create the logo

## Challenges we ran into

Our main challenge was that we wanted to develop this technology so it would interface with light-weight smart glasses, such as Focals by North. However, due to hardware limitations, we decided to implement the technology using a VR headset instead. We decided to trade off portability in order to make a prototype this weekend.

## Accomplishments that we're proud of

We are proud to have built our first app that uses AR. We were able to teach ourselves ARKit through the documentation and sample code snippets.

We are also proud to have architectured the API wrapper in such a way that it abstracts away many of the complexities that come with using Azure. We are also proud to have successfully deployed that API on Google Cloud.

## What we learned

We learned a lot of new technologies through building this project, and learned how to integrate many different technologies form different areas.

## What's next for heAR

We would like to take this technology to a pair of smart glasses, as originally planned. We also would like to add more features, such as support for language translation, multiple speech bubbles for multiple speakers, tooltips to improve sound quality.

## DevPost

[devpost.com/software/hear](https://devpost.com/software/hear-itjofg)

## Collaborators

Carolina Li, Estella Liu, Pranav Panchal, Kajoban Kuhaparan

# Ogahunt 

A real state hunting app for teams.

## Overal Arch

The system has two main parts: the REST/HTTP API backend and the iOS app as the frontend.
The former is under the `web` folder and the later under `iso`.

## Goals

The goal of this project is to provide an open source solution to capture, store and organize and analyze real state information 
as a team, allowing people to easily collaborate to identify interesting deals over time.

The current state of the app only allows to interact with the app using an iPhone but a Browser client would definitely be a better 
solution to interact with the app. 

## Roadmap

Here's a list of ideas to keep the project improving and achieve the goals listed in the previous section.

### Phase 1

The idea of this phase is to make the app as independent as possible to a specific deployment so anyone can contribute, do changes and install as they
prefer.

- [x] Make the code open source.
- [ ] Allow the iOS app to select the backend to connect to. Now is hardcoded per environment which requires anyone to publish the same app 
with a different backend, something that is probably not allowed AFAIK. 
- [ ] Improve setup and config documentation.
- [ ] Increase test quality and coverage.

### Phase 2

A better frontend experience is the goal. The iOS app is a bit limiting. A web frontend is the intention.

- [ ] Define with FW is better suited for this. E.g. Phoenix, LiveView or a SPA (i.e. React/Redux).
- [ ] Implement a 1:1 feature match with the iOS app.


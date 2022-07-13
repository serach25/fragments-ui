// src/app.js
//It should use src/auth.js to handle authentication, get the user, and update the UI

import { Auth, getUser } from './auth';
import { getUserFragments, postUserFragments, getFragmentById} from './api';


async function init() {
  // Get our UI elements
  const userSection = document.querySelector('#user');
  const loginBtn = document.querySelector('#login');
  const logoutBtn = document.querySelector('#logout');
  const createBtn = document.querySelector('#create');
  const getByIdBtn = document.querySelector('#get');
  const selectedType = document.getElementById('fragmentType');

  // Wire up event handlers to deal with login and logout.
  loginBtn.onclick = () => {
    // Sign-in via the Amazon Cognito Hosted UI (requires redirects), see:
    // https://docs.amplify.aws/lib/auth/advanced/q/platform/js/#identity-pool-federation
    Auth.federatedSignIn();
  };
  logoutBtn.onclick = () => {
    // Sign-out of the Amazon Cognito Hosted UI (requires redirects), see:
    // https://docs.amplify.aws/lib/auth/emailpassword/q/platform/js/#sign-out
    Auth.signOut();
  };

  // See if we're signed in (i.e., we'll have a `user` object)
  const user = await getUser();
  
  if (!user) {
    // Disable the Logout button
    logoutBtn.disabled = true;
    return;
  }

  // Log the user info for debugging purposes
  console.log({ user });
  
  createBtn.onclick = async () => {
    console.log('Create fragment button clicked');
    var input = document.getElementById('fragment').value;
    console.log(input);
    console.log(selectedType.value);
    await postUserFragments(user, input, selectedType.value);
  };

  getByIdBtn.onclick = () => {
    var input = document.getElementById('id').value;
    console.log(input);
    getFragmentById(user, input);
  };

  // Update the UI to welcome the user
  userSection.hidden = false;

  // Show the user's username
  userSection.querySelector('.username').innerText = user.username;

  // Disable the Login button
  loginBtn.disabled = true;

  // Do an authenticated request to the fragments API server and log the result
  getUserFragments(user);
}



 

// Wait for the DOM to be ready, then start the app
addEventListener('DOMContentLoaded', init);
function addFollowers(firebaseEvent) {
  let currentUserID = firebaseEvent.params.userID
  let users = firebaseEvent.data.val()
  let addedUserUniqueID = users[users.length - 1]

  return root.child(`users/${addedUserUniqueID}/followers`).once('value').then(snapshot => {
    if (Array.isArray(snapshot.val())) {
      var foundFollowers = snapshot.val()

      foundFollowers.push(currentUserID)

      return root.child(`users/${addedUserUniqueID}/followers`).set(foundFollowers);
    } else {
      var newFollowers = [currentUserID]

      return root.child(`users/${addedUserUniqueID}/followers`).set(newFollowers);
    }
  });

  return 0;
}

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);
var root = admin.database().ref()

exports.createAddFollowers = functions.database.ref('/users/{userID}/following').onCreate(addFollowers);
exports.updateAddFollowers = functions.database.ref('/users/{userID}/following').onUpdate(addFollowers);

exports.deleteAddFollowers= functions.database.ref('/users/{userID}/following').onDelete(event => {
  let currentUserID = event.params.userID
  let users = event.data.previous.val()
  let deletedUserUniqueID = users[users.length - 1]

  return root.child(`users/${deletedUserUniqueID}/followers`).once('value').then(snapshot => {
      var foundFollowers = snapshot.val()

      var result = foundFollowers.filter(function(foundFollowerUID) {
        if (foundFollowerUID == currentUserID) {
          return false
        } else {
          return true
        }
      })


      return root.child(`users/${deletedUserUniqueID}/followers`).set(result);
  });

  return 0;
});

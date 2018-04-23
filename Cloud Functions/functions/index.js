function addFollowers(firebaseEvent) {
  let currentUserID = firebaseEvent.params.userID
  let users = firebaseEvent.data.val()
  let previousUsers = firebaseEvent.data.previous.val()
  let addedUserUniqueID = users[users.length - 1]
  let followingCount = users.length

  if (previousUsers == null || users.length > previousUsers.length) {
    return root.child(`users/${currentUserID}/followingCount`).set(followingCount).then(function() {
      return root.child(`users/${addedUserUniqueID}/followers`).once('value').then(snapshot => {
        if (Array.isArray(snapshot.val())) {
          var foundFollowers = snapshot.val()
          foundFollowers.push(currentUserID)
          var newCount = foundFollowers.length

          return root.child(`users/${addedUserUniqueID}/followers`).set(foundFollowers).then(function() {
            return root.child(`users/${addedUserUniqueID}/followersCount`).set(newCount);
          });
        } else {
          var newFollowers = [currentUserID]
          var newCount = newFollowers.length

          return root.child(`users/${addedUserUniqueID}/followers`).set(newFollowers).then(function() {
            return root.child(`users/${addedUserUniqueID}/followersCount`).set(newCount);
          });
        }
      });
    });
  } else if (users.length < previousUsers.length) {
    let currentUserID = firebaseEvent.params.userID
    let users = firebaseEvent.data.previous.val()
    var currentlyFollowingCount = users.length - 1
    let deletedUserUniqueID = users[users.length - 1]

    return root.child(`users/${currentUserID}/followingCount`).set(currentlyFollowingCount).then(function() {
      return root.child(`users/${deletedUserUniqueID}/followers`).once('value').then(snapshot => {
          var foundFollowers = snapshot.val()

          var result = foundFollowers.filter(function(foundFollowerUID) {
            if (foundFollowerUID == currentUserID) {
              return false
            } else {
              return true
            }
          })

          var newCount = result.length

          return root.child(`users/${deletedUserUniqueID}/followers`).set(result).then(function() {
            return root.child(`users/${deletedUserUniqueID}/followersCount`).set(newCount);
          })
      });
    });
  }

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
  var currentlyFollowingCount = users.length - 1
  let deletedUserUniqueID = users[users.length - 1]

  return root.child(`users/${currentUserID}/followingCount`).set(currentlyFollowingCount).then(function() {
    return root.child(`users/${deletedUserUniqueID}/followers`).once('value').then(snapshot => {
        var foundFollowers = snapshot.val()

        var result = foundFollowers.filter(function(foundFollowerUID) {
          if (foundFollowerUID == currentUserID) {
            return false
          } else {
            return true
          }
        })

        var newCount = result.length

        return root.child(`users/${deletedUserUniqueID}/followers`).set(result).then(function() {
          return root.child(`users/${deletedUserUniqueID}/followersCount`).set(newCount);
        })
    });
  });

  return 0;
});

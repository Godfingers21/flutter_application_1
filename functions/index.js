const {onSchedule} = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");


admin.initializeApp();


/**
 * Assigns roles of "hunter" and "hassé" to members of a group daily.

 * @return {Promise<void>} A Promise that resolves when the roles are assigned.
 */

exports.assignRoles = async ()=> {
  const db = admin.firestore();

  const groupsRef = db.collection("groups");
  const snapshot = await groupsRef.get();

  snapshot.forEach(async (groupDoc) => {
    const groupId = groupDoc.id;
    const groupData = groupDoc.data();
    const members = groupData.members;

    // Mélanger aléatoirement les membres
    shuffle(members);

    // Attribuer les rôles
    await Promise.all([
      groupsRef.doc(groupId).update({hunter: members[0]}),
      groupsRef.doc(groupId).update({hunted: members[1]}),
    ]);
  });
};

/**
 * Assigns roles of "hunter" and "hassé" to members of a group daily.

 * This function is triggered by a Cloud Scheduler job to run daily.
It fetches all members of a specified group, shuffles them randomly,
and assigns the first two members as the hunter and the hunted, respectively.
The roles of the remaining members are reset.
 */

exports.assignRolesDaily = onSchedule("every 24 hours", async (context)=>{
  await exports.assignRoles();
});


/**
 * Shuffles an array randomly.

 * This function takes an array as input and rearranges its elements randomly.

 * @param {Array} array - The array to be shuffled.
 * @return {void}
 */

function shuffle(array) {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }
}

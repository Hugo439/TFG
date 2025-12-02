/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions/v2");
const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
admin.initializeApp();

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance.
setGlobalOptions({maxInstances: 10});

// Cloud Function que se ejecuta cuando se actualiza un mensaje de soporte
exports.notifySupportResponse = onDocumentUpdated(
    "support_messages/{docId}",
    async (event) => {
      const before = event.data.before.data();
      const after = event.data.after.data();

      // Solo si response cambia de null/vacío a tener un valor
      const responseChanged = (!before.response || before.response === "") &&
                            (after.response && after.response !== "");

      if (responseChanged) {
        const userId = after.userId;
        const docId = event.params.docId;

        try {
          // ACTUALIZAR EL ESTADO A "respondido" y añadir responseDate
          await admin.firestore()
              .collection("support_messages")
              .doc(docId)
              .update({
                status: "respondido",
                responseDate: admin.firestore.FieldValue.serverTimestamp(),
              });

          console.log("Estado actualizado a respondido para:", docId);

          // Busca el token FCM del usuario
          const userDoc = await admin.firestore()
              .collection("users")
              .doc(userId)
              .get();

          if (!userDoc.exists) {
            console.log("Usuario no encontrado:", userId);
            return;
          }

          const fcmToken = userDoc.data().fcmToken;

          if (fcmToken) {
            await admin.messaging().send({
              token: fcmToken,
              notification: {
                title: "Respuesta de soporte",
                body: "¡Tu mensaje ha sido respondido!",
              },
              data: {
                type: "support_response",
                messageId: docId,
              },
            });
            console.log("Notificación enviada a:", userId);
          } else {
            console.log("Token FCM no encontrado para usuario:", userId);
          }
        } catch (error) {
          console.error("Error al procesar respuesta:", error);
        }
      }
    });

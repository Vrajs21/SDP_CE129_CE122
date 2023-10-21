import 'package:canteen_food_ordering_app/models/food.dart';

import 'package:canteen_food_ordering_app/models/user.dart' as vraj;
import 'package:canteen_food_ordering_app/notifiers/authNotifier.dart';
import 'package:canteen_food_ordering_app/screens/adminHome.dart';
import 'package:canteen_food_ordering_app/screens/login.dart';
import 'package:canteen_food_ordering_app/screens/navigationBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

 ProgressDialog ?pr;
 ProgressDialog? pr1;

void toast(String data) {
  Fluttertoast.showToast(
      msg: data,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      timeInSecForIosWeb: 5);
}

login(vraj.User?user, AuthNotifier authNotifier, BuildContext context) async {
  pr = new ProgressDialog(context,
      type: ProgressDialogType.normal, isDismissible: false, showLogs: false);
  pr?.show();
  UserCredential authResult;
  try {
    authResult = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: user!.email!, password: user!.password!);
  } catch (error) {
    pr?.hide().then((isHidden) {
      print(isHidden);
    });
    if (error is Exception) {
      toast(error.toString());
    } else {
      toast('An unknown error occurred');
    }
    print(error);
    return;
  }

  try {
    if (authResult != null) {
      User? firebaseUser = authResult.user;
      if (firebaseUser!.emailVerified) {
        await FirebaseAuth.instance.signOut();
        pr?.hide().then((isHidden) {
          print(isHidden);
        });
        toast("Email ID not verified");
        return;
      } else if (firebaseUser != null) {
        print("Log In: $firebaseUser");
        authNotifier.setUser(firebaseUser);
        await getUserDetails(authNotifier);
        print("done");
        pr?.hide().then((isHidden) {
          print(isHidden);
        });
        if (authNotifier.userDetails?.role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (BuildContext context) {
              return AdminHomePage();
            }),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (BuildContext context) {
              return NavigationBarPage(selectedIndex: 1);
            }),
          );
        }
      }
    }
  } catch (error) {
    pr?.hide().then((isHidden) {
      print(isHidden);
    });
    if (error is Exception) {
      toast(error.toString());
    } else {
      toast('An unknown error occurred');
    }
    print(error);
    return;
  }
}

signUp(vraj.User? user, AuthNotifier authNotifier, BuildContext context) async {
  pr = new ProgressDialog(context,
      type: ProgressDialogType.normal, isDismissible: false, showLogs: false);
  pr?.show();
  bool userDataUploaded = false;
  UserCredential authResult;
  try {
    authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user!.email!.trim(), password: user.password!);
  } catch (error) {
    pr?.hide().then((isHidden) {
      print(isHidden);
    });
    if (error is Exception) {
      toast(error.toString());
    } else {
      toast('An unknown error occurred');
    }
    print(error);
    return;
  }

  try {
    if (authResult != null) {

      User? firebaseUser = authResult.user;
      await firebaseUser?.sendEmailVerification();

      if (firebaseUser != null) {
        await firebaseUser.updateDisplayName(user.displayName);
        await firebaseUser.reload();
        print("Sign Up: $firebaseUser");
        uploadUserData(user as vraj.User, userDataUploaded);
        await FirebaseAuth.instance.signOut();
        authNotifier.setUser("\0" as User);
        pr?.hide().then((isHidden) {
          print(isHidden);
        });
        toast("Verification link is sent to ${user.email}");
        Navigator.pop(context);
      }
    }
    pr?.hide().then((isHidden) {
      print(isHidden);
    });
  } catch (error) {
    pr?.hide().then((isHidden) {
      print(isHidden);
    });
    if (error is Exception) {
      toast(error.toString());
    } else {
      toast('An unknown error occurred');
    }
    print(error);
    return;
  }
}

getUserDetails(AuthNotifier authNotifier) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(authNotifier.user?.uid)
      .get()
      .catchError((e) => print(e))
      .then((value) => {
            (value != null)
                ? authNotifier.setUserDetails(vraj.User.fromMap(value.data as Map<String, dynamic>))
                : print(value)
          });
}

uploadUserData(vraj.User user, bool userdataUpload) async {
  bool userDataUploadVar = userdataUpload;
  User currentUser = await FirebaseAuth.instance.currentUser!;

  CollectionReference userRef = FirebaseFirestore.instance.collection('users');
  CollectionReference cartRef = FirebaseFirestore.instance.collection('carts');

  user.uuid = currentUser.uid;
  if (userDataUploadVar != true) {
    await userRef
        .doc(currentUser.uid)
        .set(user.toMap())
        .catchError((e) => print(e))
        .then((value) => userDataUploadVar = true);
    await cartRef
        .doc(currentUser.uid)
        .set({})
        .catchError((e) => print(e))
        .then((value) => userDataUploadVar = true);
  } else {
    print('already uploaded user data');
  }
  print('user data uploaded successfully');
}

initializeCurrentUser(AuthNotifier authNotifier, BuildContext context) async {
  User ? firebaseUser = await FirebaseAuth.instance.currentUser;
  if (firebaseUser != null) {
    authNotifier.setUser(firebaseUser);
    await getUserDetails(authNotifier);
  }
}

signOut(AuthNotifier authNotifier, BuildContext context) async {
  await FirebaseAuth.instance.signOut();

  authNotifier.setUser("\0" as User);
  print('log out');
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (BuildContext context) {
      return LoginPage();
    }),
  );
}

forgotPassword(
    vraj.User?user, AuthNotifier authNotifier, BuildContext context) async {
  pr = new ProgressDialog(context,
      type: ProgressDialogType.normal, isDismissible: false, showLogs: false);
  pr?.show();
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
  } catch (error) {
    pr?.hide().then((isHidden) {
      print(isHidden);
    });
    if (error is Exception) {
      toast(error.toString());
    } else {
      toast('An unknown error occurred');
    }
    print(error);
    return;
  }
  pr?.hide().then((isHidden) {
    print(isHidden);
  });
  toast("Reset Email has sent successfully");
  Navigator.pop(context);
}

addToCart(Food food, BuildContext context) async {
  pr = new ProgressDialog(context,
      type: ProgressDialogType.normal, isDismissible: false, showLogs: false);

  void onPreExecute() {
    pr?.show();
  }

  pr?.show();
  try {
    pr?.hide().then((isHidden) {
      print(isHidden);
    });
    User currentUser = await FirebaseAuth.instance.currentUser!;
    CollectionReference cartRef = FirebaseFirestore.instance.collection('carts');
    QuerySnapshot data = await cartRef
        .doc(currentUser.uid)
        .collection('items')
        .get();
    if (data.docs.length >= 10) {
      pr?.hide().then((isHidden) {
        print(isHidden);
      });
      toast("Cart cannot have more than 10 times!");
      return;
    }
    await cartRef
        .doc(currentUser.uid)
        .collection('items')
        .doc(food.id)
        .set({"count": 1})
        .catchError((e) => print(e))
        .then((value) => print("Success"));

    pr?.hide().then((isHidden) {
      print(isHidden);
    });
  } catch (error) {
    pr?.hide().then((isHidden) {
      print(isHidden);
    });
    toast("Failed to add to cart!");
    print(error);
    return;
  }
  pr?.hide().then((isHidden) {
    print(isHidden);
  });

  toast("Added to cart successfully!");
}

removeFromCart(Food food, BuildContext context) async {
  pr = new ProgressDialog(context,
      type: ProgressDialogType.normal, isDismissible: false, showLogs: false);
  pr?.show();
  try {
    pr?.hide().then((isHidden) {
      print(isHidden);
    });
    User currentUser = await FirebaseAuth.instance.currentUser!;
    CollectionReference cartRef = FirebaseFirestore.instance.collection('carts');
    await cartRef
        .doc(currentUser.uid)
        .collection('items')
        .doc(food.id)
        .delete()
        .catchError((e) => print(e))
        .then((value) => print("Success"));

    pr?.hide().then((isHidden) {
      print(isHidden);
    });
  } catch (error) {
    pr?.hide().then((isHidden) {
      print(isHidden);
    });
    toast("Failed to Remove from cart!");
    print(error);
    return;
  }
  pr?.hide().then((isHidden) {
    print(isHidden);
  });
  toast("Removed from cart successfully!");
}

addNewItem(
    String? itemName, int totalQty ,int price, BuildContext ?context) async {
  pr = new ProgressDialog(context!,
      type: ProgressDialogType.normal, isDismissible: false, showLogs: false);
  pr?.show();
  try {
    CollectionReference itemRef = FirebaseFirestore.instance.collection('items');
    await itemRef
        .doc()
        .set({"item_name": itemName, "price": price, "total_qty": totalQty})
        .catchError((e) => print(e))
        .then((value) => print("Success"));
  } catch (error) {
    pr?.hide().then((isHidden) {
      print(isHidden);
    });
    toast("Failed to add to new item!");
    print(error);
    return;
  }
  pr?.hide().then((isHidden) {
    print(isHidden);
  });
  Navigator.pop(context);
  toast("New Item added successfully!");
}

editItem(String itemName, int price, int totalQty, BuildContext context,
    String id) async {
  pr = new ProgressDialog(context,
      type: ProgressDialogType.normal, isDismissible: false, showLogs: false);
  pr?.show();
  try {
    CollectionReference itemRef = FirebaseFirestore.instance.collection('items');
    await itemRef
        .doc(id)
        .set({"item_name": itemName, "price": price, "total_qty": totalQty})
        .catchError((e) => print(e))
        .then((value) => print("Success"));
  } catch (error) {
    pr?.hide().then((isHidden) {
      print(isHidden);
    });
    toast("Failed to edit item!");
    print(error);
    return;
  }
  pr?.hide().then((isHidden) {
    print(isHidden);
  });
  Navigator.pop(context);
  toast("Item edited successfully!");
}

deleteItem(String id, BuildContext context) async {
  pr = new ProgressDialog(context,
      type: ProgressDialogType.normal, isDismissible: false, showLogs: false);
  pr?.show();
  try {
    CollectionReference itemRef = FirebaseFirestore.instance.collection('items');
    await itemRef
        .doc(id)
        .delete()
        .catchError((e) => print(e))
        .then((value) => print("Success"));
  } catch (error) {
    pr?.hide().then((isHidden) {
      print(isHidden);
    });
    toast("Failed to edit item!");
    print(error);
    return;
  }
  pr?.hide().then((isHidden) {
    print(isHidden);
  });
  Navigator.pop(context);
  toast("Item edited successfully!");
}

editCartItem(String itemId, int count, BuildContext context) async {
  pr = new ProgressDialog(context,
      type: ProgressDialogType.normal, isDismissible: false, showLogs: false);
  pr?.show();
  try {
    User currentUser = await FirebaseAuth.instance.currentUser!;
    CollectionReference cartRef = FirebaseFirestore.instance.collection('carts');
    if (count <= 0) {
      await cartRef
          .doc(currentUser.uid)
          .collection('items')
          .doc(itemId)
          .delete()
          .catchError((e) => print(e))
          .then((value) => print("Success"));
    } else {
      await cartRef
          .doc(currentUser.uid)
          .collection('items')
          .doc(itemId)
          .update({"count": count})
          .catchError((e) => print(e))
          .then((value) => print("Success"));
    }
    pr?.hide().then((isHidden) {
      print(isHidden);
    });
  } catch (error) {
    pr?.hide().then((isHidden) {
      print(isHidden);
    });
    toast("Failed to update Cart!");
    print(error);
    return;
  }
  pr?.hide().then((isHidden) {
    print(isHidden);
  });
  toast("Cart updated successfully!");
}

addMoney(int amount, BuildContext context, String id) async {
  pr = new ProgressDialog(context,
      type: ProgressDialogType.normal, isDismissible: false, showLogs: false);
  pr?.show();
  try {
    CollectionReference userRef = FirebaseFirestore.instance.collection('users');
    await userRef
        .doc(id)
        .update({'balance': FieldValue.increment(amount)})
        .catchError((e) => print(e))
        .then((value) => print("Success"));
  } catch (error) {
    pr?.hide().then((isHidden) {
      print(isHidden);
    });
    toast("Failed to add money!");
    print(error);
    return;
  }
  pr?.hide().then((isHidden) {
    print(isHidden);
  });
  Navigator.pop(context);
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (BuildContext context) {
      return NavigationBarPage(selectedIndex: 2);
    }),
  );
  toast("Money added successfully!");
}

var now = new DateTime.now();
var formatter = new DateFormat('dd-MM-yyyy');
String formattedDate = formatter.format(now);

placeOrder(
  BuildContext context,
  double total,
  String deliveryTime,
) async {
  pr = new ProgressDialog(context,
      type: ProgressDialogType.normal, isDismissible: false, showLogs: false);
  pr?.show();
  try {
    // Initiaization
    User currentUser = await FirebaseAuth.instance.currentUser!;
    CollectionReference cartRef = FirebaseFirestore.instance.collection('carts');
    DocumentReference orderRef =
        FirebaseFirestore.instance.collection('orders').doc();

    CollectionReference itemRef = FirebaseFirestore.instance.collection('items');
    CollectionReference userRef = FirebaseFirestore.instance.collection('users');
    // DocumentReference tokenRef =
    //     FirebaseFirestore.instance.collection('token').document(formattedDate);
    int tokenNo;
    Future<int> gettoken() async {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('token')
            .doc(formattedDate)
            .get();

        tokenNo = doc['tokenNo'];
        return tokenNo;
      } catch (e) {
        toast('$e');
        return -1; // return a default value
      }
    }


    List<String> foodIds = [];
    Map<String, int> count = {};
    List<dynamic> _cartItems = [];

// Checking user balance
    DocumentSnapshot userData = await userRef.doc(currentUser.uid).get();
    Map<String, dynamic>? data = userData.data() as Map<String, dynamic>?;
    if (data != null && data['balance'] < total) {
      pr?.hide().then((isHidden) {
        print(isHidden);
      });
      toast("You don't have sufficient balance to place this order!");
      return;
    }


    // Getting all cart items of the user
    QuerySnapshot datagg = await cartRef
        .doc(currentUser.uid)
        .collection('items')
        .get();
    datagg.docs.forEach((item) {
      foodIds.add(item.id);
      Map<String, dynamic>? data = item.data() as Map<String, dynamic>?;
      if (data != null && data['count'] != null) {
        count[item.id] = data['count'];
      }
    });

    // Checking for item availability
    QuerySnapshot snap = await itemRef
        .where(FieldPath.documentId, whereIn: foodIds)
        .get();
    for (var i = 0; i < snap.docs.length; i++) {
      var doc = snap.docs[i];
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null && data['total_qty'] != null && count[doc.id] != null && data['total_qty'] < count[doc.id]) {
        pr?.hide().then((isHidden) {
          print(isHidden);
        });
        print("not");
        toast(
            "Item: ${data['item_name']} has QTY: ${data['total_qty']} only. Reduce/Remove the item.");
        return;
      }
    }


    // Creating cart items array
    snap.docs.forEach((item) {
      Map<String, dynamic>? data = item.data() as Map<String, dynamic>?;
      if (data != null) {
        _cartItems.add({
          "item_id": item.id,
          "count": count[item.id],
          "item_name": data['item_name'],
          "price": data['price']
        });
      }
    });

    // Creating a transaction
    await FirebaseFirestore.instance.runTransaction((Transaction transaction) async {
      // Update the item count in items table
      for (var i = 0; i < snap.docs.length; i++) {
        var doc = snap.docs[i];
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data["total_qty"] != null && count[doc.id] != null) {
          await transaction.update(doc.reference, {
            "total_qty": data["total_qty"] - count[doc.id]
          });
        }
      }
    });


    // Deduct amount from user
      await userRef
          .doc(currentUser.uid)
          .update({'balance': FieldValue.increment(-1 * total)});

      int tokenNod = await gettoken();
      // Place a new order
      await orderRef.set({
        "orderID": orderRef.id,
        "itemdetails": _cartItems,
        "is_RedPre": false,
        "is_OrgReady": false,
        "is_GrnDel": false,
        "total": total,
        "placed_at": DateTime.now(),
        "token": '${DateTime.now().day}/${DateTime.now().month}_$tokenNod',
        "delivery_time": deliveryTime,
        "placed_by": currentUser.displayName,
        "placed_uid": currentUser.uid,
        "todayDate": formattedDate,
      });

      // Empty cart
    await FirebaseFirestore.instance.runTransaction((Transaction transaction) async {
        for (var i = 0; i < datagg.docs.length; i++) {
        await transaction.delete(datagg.docs[i].reference);
      }
      print("in in");
      // return;
    });

    // Successfull transaction
    pr?.hide().then((isHidden) {
      print(isHidden);
    });
    Navigator.pop(context);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return NavigationBarPage(selectedIndex: 1);
      }),
    );
    toast("Order Placed Successfully!");
  } catch (error) {
    pr?.hide().then((isHidden) {
      print(isHidden);
    });
    Navigator.pop(context);
    toast("Failed to place order!");
    print(error);
    return;
  }
}

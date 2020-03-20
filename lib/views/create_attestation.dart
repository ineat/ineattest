import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ineattest/extensions/i18n.dart';
import 'package:ineattest/model/attestation.dart';
import 'package:ineattest/preferences/preferences.dart';
import 'package:ineattest/views/attestation_viewer.dart';
import 'package:ineattest/views/progress.dart';
import 'package:ineattest/views/signature.dart';

class CreateAttestation extends HookWidget {
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _birthdayFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _zipcodeFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final nameTextEditingController = useTextEditingController();
    final birthdayEditingController = useTextEditingController();
    final addressEditingController = useTextEditingController();
    final zipEditingController = useTextEditingController();
    final cityEditingController = useTextEditingController();
    final reasonState = useState<AttestationReason>(null);
    final attestationFuture = useMemoized(() => Preferences.getAttestation());
    final attestationSnapshot = useFuture(attestationFuture);
    final oldBirthdayValue = useState("");

    useValueChanged(attestationSnapshot, (_, __) {
      nameTextEditingController.text = attestationSnapshot?.data?.name;
      addressEditingController.text = attestationSnapshot?.data?.address;
      cityEditingController.text = attestationSnapshot?.data?.city;
      zipEditingController.text = attestationSnapshot?.data?.zip;
      birthdayEditingController.text = attestationSnapshot?.data?.birthday;
      reasonState.value = attestationSnapshot?.data?.reason;
    });
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.all(10),
          child: Hero(
            tag: "poulpy",
            child: Image.asset("assets/poulpy.png"),
          ),
        ),
        actions: <Widget>[
          Offstage(
            offstage: !Navigator.of(context).canPop(),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.close),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SafeArea(
          child: Builder(builder: (context) {
            if (attestationSnapshot.connectionState != ConnectionState.done) {
              return Progress();
            }
            return ListView(
              padding: const EdgeInsets.all(8.0) + const EdgeInsets.only(bottom: 24.0),
              children: <Widget>[
                TextFormField(
                  controller: nameTextEditingController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: "create-attestation.sir-madam".translate(context),
                  ),
                  autocorrect: false,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  focusNode: _nameFocus,
                  onFieldSubmitted: (_) => _nextFocus(context, _nameFocus, _birthdayFocus),
                ),
                TextFormField(
                  controller: birthdayEditingController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "create-attestation.born-the".translate(context),
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(10)],
                  onChanged: (_) {
                    _onBirthdayChanged(oldBirthdayValue, birthdayEditingController);
                  },
                  textInputAction: TextInputAction.next,
                  focusNode: _birthdayFocus,
                  onFieldSubmitted: (_) => _nextFocus(context, _birthdayFocus, _addressFocus),
                ),
                TextFormField(
                  controller: addressEditingController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: "create-attestation.address".translate(context),
                  ),
                  textInputAction: TextInputAction.next,
                  focusNode: _addressFocus,
                  onFieldSubmitted: (_) => _nextFocus(context, _addressFocus, _cityFocus),
                ),
                TextFormField(
                  controller: cityEditingController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: "create-attestation.city".translate(context),
                  ),
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  focusNode: _cityFocus,
                  onFieldSubmitted: (_) => _nextFocus(context, _cityFocus, _zipcodeFocus),
                ),
                TextFormField(
                  controller: zipEditingController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "create-attestation.zip-code".translate(context),
                  ),
                  textInputAction: TextInputAction.next,
                  focusNode: _zipcodeFocus,
                  onFieldSubmitted: (_) => _nextFocus(context, _zipcodeFocus, null),
                ),
                _FormDivider(),
                Text("create-attestation.choose-reason".translate(context)),
                _FormDivider(),
                ...AttestationReason.values
                    .map(
                      (AttestationReason reason) => ReasonTile(
                        onTap: () {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          reasonState.value = reason;
                        },
                        reason: reason,
                        selectedReason: reasonState,
                      ),
                    )
                    .toList(),
                _FormDivider(),
                Text("create-attestation.signature".translate(context)),
                _FormDivider(),
                AspectRatio(
                  aspectRatio: 1,
                  child: Signature(),
                ),
                _FormDivider(),
                FlatButton(
                  child: Text("action.validate".translate(context), style: TextStyle(color: Colors.white)),
                  color: Theme.of(context).accentColor,
                  onPressed: () {
                    final name = nameTextEditingController.text;
                    final birthday = birthdayEditingController.text;
                    final address = addressEditingController.text;
                    final zip = zipEditingController.text;
                    final city = cityEditingController.text;
                    final attestation = Attestation(
                      name: name,
                      birthday: birthday,
                      city: city,
                      address: address,
                      zip: zip,
                      reason: reasonState.value,
                    );

                    Preferences.saveAttestation(attestation).then((_) {
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => AttestationViewer()), ModalRoute.withName("/"));
                    });
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  void _nextFocus(BuildContext context, FocusNode current, FocusNode next) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next ?? FocusNode());
  }

  void _onBirthdayChanged(ValueNotifier<String> oldBirthdayValue, TextEditingController birthdayEditingController) {
    final value = birthdayEditingController.text;
    if (oldBirthdayValue.value.length > value.length) {
      oldBirthdayValue.value = value;
      return;
    }
    String newVal = value;
    if (value.length == 0) oldBirthdayValue.value = "";
    if (value.length == 2) {
      newVal = value + "/";
    } else if (value.length == 5) {
      newVal = value + "/";
    }
    oldBirthdayValue.value = newVal;
    birthdayEditingController.text = newVal;
    birthdayEditingController.selection = TextSelection.collapsed(offset: newVal.length);
  }
}

class ReasonTile extends StatelessWidget {
  final AttestationReason reason;
  final ValueNotifier<AttestationReason> selectedReason;
  final VoidCallback onTap;

  const ReasonTile({
    Key key,
    this.reason,
    this.selectedReason,
    this.onTap,
  }) : super(key: key);

  String _getIconName(AttestationReason reason) => reason.toValueString();

  @override
  Widget build(BuildContext context) {
    final isSelected = reason == selectedReason.value;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: this.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeIn,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.black,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
            child: Row(
              children: <Widget>[
                Image.asset(
                  "assets/${_getIconName(reason)}.png",
                  width: 30,
                  height: 30,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      "create-attestation.reason.${reason.toValueString()}".translate(context),
                      style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 16.0);
  }
}

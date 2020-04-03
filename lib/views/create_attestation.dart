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
  final _formKey = GlobalKey<FormState>();
  final _reasonGroupKey = GlobalKey();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _birthdayFocus = FocusNode();
  final FocusNode _birthplaceFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _zipcodeFocus = FocusNode();

  final nameRegExp = RegExp(r"([^ ]{3,}) ([^ ]{3,})");
  final birthdayRegExp = RegExp(r"[0-9]{2}\/[0-9]{2}\/[0-9]{4}");

  @override
  Widget build(BuildContext context) {
    final nameTextEditingController = useTextEditingController();
    final birthdayEditingController = useTextEditingController();
    final birthplaceEditingController = useTextEditingController();
    final addressEditingController = useTextEditingController();
    final zipEditingController = useTextEditingController();
    final cityEditingController = useTextEditingController();

    final scrollController = useListenable(ScrollController());
    final reasonState = useState<AttestationReason>(AttestationReason.work);
    final attestationFuture = useMemoized(() => Preferences.getAttestation());
    final attestationSnapshot = useFuture(attestationFuture);
    final oldBirthdayValue = useState("");
    final autoValidateForm = useState(false);

    useEffect(() {
      nameTextEditingController.text = attestationSnapshot?.data?.name;
      addressEditingController.text = attestationSnapshot?.data?.address;
      cityEditingController.text = attestationSnapshot?.data?.city;
      zipEditingController.text = attestationSnapshot?.data?.zip;
      birthdayEditingController.text = attestationSnapshot?.data?.birthday;
      birthplaceEditingController.text = attestationSnapshot?.data?.birthplace;
      reasonState.value = attestationSnapshot?.data?.reason;
      return null;
    }, [attestationSnapshot]);

//    useValueChanged(attestationSnapshot, (_, __) {
//      nameTextEditingController.text = attestationSnapshot?.data?.name;
//      addressEditingController.text = attestationSnapshot?.data?.address;
//      cityEditingController.text = attestationSnapshot?.data?.city;
//      zipEditingController.text = attestationSnapshot?.data?.zip;
//      birthdayEditingController.text = attestationSnapshot?.data?.birthday;
//      birthplaceEditingController.text = attestationSnapshot?.data?.birthplace;
//      reasonState.value = attestationSnapshot?.data?.reason;
//    });
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.all(10),
          child: Hero(
            tag: "poulpy",
            child: Image.asset("assets/poulpy.png"),
          ),
        ),
        title: Text("create-attestation.title".translate(context)),
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
        child: Builder(builder: (context) {
          if (attestationSnapshot.connectionState != ConnectionState.done) {
            return Progress();
          }
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(8.0) + const EdgeInsets.only(bottom: 48.0),
            child: Form(
              key: _formKey,
              autovalidate: autoValidateForm.value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    controller: nameTextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "create-attestation.sir-madam".translate(context),
                    ),
                    validator: (value) => !nameRegExp.hasMatch(value) ? "create-attestation.error.sir-madam".translate(context) : null,
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
                    validator: (value) => !birthdayRegExp.hasMatch(value) ? "create-attestation.error.born-the".translate(context) : null,
                    textInputAction: TextInputAction.next,
                    focusNode: _birthdayFocus,
                    onFieldSubmitted: (_) => _nextFocus(context, _birthdayFocus, _birthplaceFocus),
                  ),
                  TextFormField(
                    controller: birthplaceEditingController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "create-attestation.born-in".translate(context),
                    ),
                    validator: (value) {
                      return value.isEmpty ? "create-attestation.error.born-in".translate(context) : null;
                    },
                    textInputAction: TextInputAction.next,
                    focusNode: _birthplaceFocus,
                    onFieldSubmitted: (_) => _nextFocus(context, _birthplaceFocus, _addressFocus),
                  ),
                  TextFormField(
                    controller: addressEditingController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "create-attestation.address".translate(context),
                    ),
                    validator: (value) => value.isEmpty ? "create-attestation.error.address".translate(context) : null,
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
                    validator: (value) => value.isEmpty ? "create-attestation.error.city".translate(context) : null,
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
                    validator: (value) => value.isEmpty ? "create-attestation.error.zip-code".translate(context) : null,
                    textInputAction: TextInputAction.next,
                    focusNode: _zipcodeFocus,
                    onFieldSubmitted: (_) => _nextFocus(context, _zipcodeFocus, null),
                  ),
                  _FormDivider(),
                  Text(
                    "create-attestation.choose-reason".translate(context),
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  _FormDivider(),
                  ListView.separated(
                    key: _reasonGroupKey,
                    primary: false,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final reason = AttestationReason.values[index];
                      return _ReasonTile(
                        onTap: () {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          reasonState.value = reason;
                        },
                        reason: reason,
                        selectedReason: reasonState,
                      );
                    },
                    separatorBuilder: (_, __) => SizedBox(height: 12.0),
                    itemCount: AttestationReason.values.length,
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    "create-attestation.signature".translate(context),
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  _FormDivider(),
                  AspectRatio(
                    aspectRatio: 1,
                    child: Signature(),
                  ),
                  _FormDivider(),
                  FlatButton(
                    child: Text("action.validate".translate(context), style: TextStyle(color: Colors.white)),
                    color: Theme.of(context).accentColor,
                    onPressed: () async {

                      final displaySnackbarError = (String keyError) {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(keyError.translate(context)),
                          backgroundColor: Colors.redAccent,
                          duration: Duration(seconds: 2),
                        ));
                      };

                      if (!_formKey.currentState.validate()) {
                        autoValidateForm.value = true;
                        scrollController.animateTo(
                          0,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.decelerate,
                        );
                        displaySnackbarError("create-attestation.error.global-message-form");
                        return;
                      }

                      if (reasonState.value == null) {
                        Scrollable.ensureVisible(
                          _reasonGroupKey.currentContext,
                          alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.decelerate,
                        );

                        displaySnackbarError("create-attestation.error.reason");
                        return;
                      }

                      if (!(await Preferences.hasSignature())) {
                        displaySnackbarError("create-attestation.error.signature");
                        return;
                      }

                      final attestation = Attestation(
                        name: nameTextEditingController.text,
                        birthday: birthdayEditingController.text,
                        birthplace: birthplaceEditingController.text,
                        city: cityEditingController.text,
                        address: addressEditingController.text,
                        zip: zipEditingController.text,
                        reason: reasonState.value,
                        createdAt: DateTime.now(),
                      );

                      Preferences.saveAttestation(attestation).then((_) {
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => AttestationViewer()), ModalRoute.withName("/"));
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        }),
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

class _ReasonTile extends StatelessWidget {
  final AttestationReason reason;
  final ValueNotifier<AttestationReason> selectedReason;
  final VoidCallback onTap;

  static final Map<String, IconData> _icons = {
    'work': Icons.card_travel,
    'food': Icons.shopping_cart,
    'health': Icons.local_hospital,
    'family': Icons.child_care,
    'sport': Icons.rowing,
    'judical': Icons.gavel,
    'voluntary': Icons.assignment,
  };

  const _ReasonTile({
    Key key,
    this.reason,
    this.selectedReason,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = reason == selectedReason.value;
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeIn,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black,
          width: isSelected ? 3.0 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: this.onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
          child: Row(
            children: <Widget>[
              Icon(
                _icons[reason.toValueString()],
                size: 30.0,
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
    );
  }
}

class _FormDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 16.0);
  }
}

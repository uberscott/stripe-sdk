import 'package:awesome_card/credit_card.dart';
import 'package:awesome_card/style/card_background.dart';
import 'package:flutter/material.dart';

import '../model/card.dart';
import 'card_cvc_form_field.dart';
import 'card_expiry_form_field.dart';
import 'card_number_form_field.dart';

/// Basic form to add or edit a credit card, with complete validation.
class CardForm extends StatefulWidget {
  CardForm({
    Key key,
    formKey,
    card,
    this.cardNumberDecoration,
    this.cardNumberTextStyle,
    this.cardExpiryDecoration,
    this.cardExpiryTextStyle,
    this.cardCvcDecoration,
    this.cardCvcTextStyle,
    this.cardNumberErrorText,
    this.cardExpiryErrorText,
    this.cardCvcErrorText,
  })  : this.card = card ?? StripeCard(),
        this.formKey = formKey ?? GlobalKey(),
        super(key: key);

  final GlobalKey<FormState> formKey;
  final StripeCard card;
  final InputDecoration cardNumberDecoration;
  final TextStyle cardNumberTextStyle;
  final InputDecoration cardExpiryDecoration;
  final TextStyle cardExpiryTextStyle;
  final InputDecoration cardCvcDecoration;
  final TextStyle cardCvcTextStyle;
  final String cardNumberErrorText;
  final String cardExpiryErrorText;
  final String cardCvcErrorText;

  @override
  _CardFormState createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  StripeCard _validationModel = StripeCard();
  bool cvcHasFocus = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cardExpiry = "MM/YY";
    if (_validationModel.expMonth != null) {
      cardExpiry = "${_validationModel.expMonth}/${_validationModel.expYear ?? 'YY'}";
    }

    return
          Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Align(alignment: Alignment.center, child: ConstrainedBox( constraints: BoxConstraints( maxWidth: 512, maxHeight: 256), child:CreditCard(
            cardNumber: _validationModel.number ?? "",
            cardExpiry: cardExpiry,
            cvv: _validationModel.cvc ?? "",
            frontBackground: CardBackgrounds.black,
            backBackground: CardBackgrounds.white,
            showBackSide: cvcHasFocus,
            showShadow: true,
          ))),
        ),
        Form(
          key: widget.formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  margin: const EdgeInsets.only(top: 16),
                  child: CardNumberFormField(
                    initialValue: _validationModel.number ?? widget.card.number,
                    onChanged: (number) {
                      setState(() {
                        _validationModel.number = number;
                      });
                    },
                    validator: (text) => _validationModel.validateNumber()
                        ? null
                        : widget.cardNumberErrorText ?? CardNumberFormField.defaultErrorText,
                    textStyle: widget.cardNumberTextStyle ?? CardNumberFormField.defaultTextStyle,
                    onSaved: (text) => widget.card.number = text,
                    decoration: widget.cardNumberDecoration ?? CardNumberFormField.defaultDecoration,
                  ),
                ),
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    margin: const EdgeInsets.only(top: 8),
                    child: CardExpiryFormField(
                      initialMonth: _validationModel.expMonth ?? widget.card.expMonth,
                      initialYear: _validationModel.expYear ?? widget.card.expYear,
                      onChanged: (int month, int year) {
                        setState(() {
                          _validationModel.expMonth = month;
                          _validationModel.expYear = year;
                        });
                      },
                      onSaved: (int month, int year) {
                        widget.card.expMonth = month;
                        widget.card.expYear = year;
                      },
                      validator: (text) => _validationModel.validateDate()
                          ? null
                          : widget.cardExpiryErrorText ?? CardExpiryFormField.defaultErrorText,
                      textStyle: widget.cardExpiryTextStyle ?? CardExpiryFormField.defaultTextStyle,
                      decoration: widget.cardExpiryDecoration ?? CardExpiryFormField.defaultDecoration,
                    )),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  margin: const EdgeInsets.only(top: 8),
                  child: FocusScope(
                    skipTraversal: false,
                    onFocusChange: (value) => setState(() => this.cvcHasFocus = value),
                    child: CardCvcFormField(
                      initialValue: _validationModel.cvc ?? widget.card.cvc,
                      onChanged: (text) => setState(() => _validationModel.cvc = text),
                      onSaved: (text) => widget.card.cvc = text,
                      validator: (text) => _validationModel.validateCVC()
                          ? null
                          : widget.cardCvcErrorText ?? CardCvcFormField.defaultErrorText,
                      textStyle: widget.cardCvcTextStyle ?? CardCvcFormField.defaultTextStyle,
                      decoration: widget.cardCvcDecoration ?? CardCvcFormField.defaultDecoration,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

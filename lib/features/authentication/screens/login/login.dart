import 'package:flutter/material.dart';
import 'package:hijaby_app/common/styles/spacing_styles.dart';
import 'package:hijaby_app/utils/constants/sizes.dart';
import 'package:hijaby_app/utils/text_strings.dart';
import 'package:hijaby_app/utils/constants/colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
      child: Padding(
        padding: TSpacingStyle.paddingWithAppBarHeight,
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TTexts.loginTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: TSizes.sm),
                Text(
                  TTexts.loginTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),

            Form(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical:TSizes.spaceBtwSections ),
                child: Column(
                  children: [
                    //email
                    TextFormField(
                      decoration: const InputDecoration(labelText: TTexts.email),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    //password
                    TextFormField(
                      decoration: const InputDecoration(labelText: TTexts.password),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields / 2),

                    //remember me & forget password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // remember me 
                        Row(
                          children: [
                            Checkbox(value: true, onChanged: (value){}),
                            const Text(TTexts.rememberMe),
                          ],
                        ),

                        //forget password
                        TextButton(
                          onPressed: (){},
                          child: const Text(TTexts.forgetPossword),
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),

                    // sign in button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (){},
                        child: const Text(TTexts.signIn),
                      ),
                    ),

                    const SizedBox(height: TSizes.spaceBtwItems),

                    //create account button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: (){},
                        child: const Text(TTexts.creoteAccount),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),
                  ],
                ),
              ),
            ),

            //divider
            Row(
              mainAxisAlignment:MainAxisAlignment.center ,
              children: [
                Flexible(child:  Divider(thickness: 0.5,indent: 60, endIndent: 5 )),
                Text(TTexts.orSignInwith, style:Theme.of(context).textTheme.labelMedium),
                Flexible(child:  Divider(thickness: 0.5,indent: 5, endIndent: 60 )),
              ],
            ),

          

          ],
        ),
      ),
    ),
  );
}

}
---
title: Labelled lists examples
labelled-lists:
  delimiter: )
  disable-citations: false
---

# List labels and delimiters

Default delimiter format set to  "...)".

Labelled list

* [Premise 1]{} This is the first claim. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. 
* [Premise 2]{} This is the second claim. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. 
* [Conclusion]{} This is the conclusion. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. 

Setting the delimiter for an individual list

* [Label 1]{delimiter='**%1**'} This is the first item. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. 
* [Label 2]{} This is the second item. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

Empty list

* []{delimiter=''} This is the first item. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. 
* []{} This is the second item. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

# Cross-referencing

Assigning identifiers to list items. Arbitrary markdown formatting on
labels will be preserved in crossreferencing.

* [**A1**]{#A1ref} This is the first claim.
* [A2]{#A2ref} This is the second claim.
* [*C*]{#Cref} This is the conclusion.

Crossreferencing items with the citation syntax

Normal citation [@A1ref]. In-text reference, see @A2ref. Year-only
citations are treated as normal ones [-@Cref]. Referencing several
items [@A1ref; @A2ref].

Crossreferencing items with links

The claim [](#A1ref) together with [the next claim](#A2ref) 
entail ([](#Cref)).

# More examples and tests

## Math formulas

* [$p_1$]{} This list uses
* [$p_2$]{} math formulas as labels.

## LaTeX code

* [\textbf{a}]{} This list uses
* [\textbf{b}]{} latex code as labels.

Ignored: these are not treated as labels.

## Small caps

* [[All]{.smallcaps}]{} This list uses
* [[Some]{.smallcaps}]{} latex code as labels.

## List with Para items

* [A1]{} $$F(x) > G(x)$$
* [A2]{} $$G(x) > H(x)$$

## items with several blocks

* [**B1**]{} This list's items

    consist of several blocks

    $$\sum_i Fi > \sum_i Gi$$

* [**B2**]{} Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec et
  massa ut eros volutpat gravida ut vel lacus. Proin turpis eros, imperdiet sed
  quam eget, bibendum aliquam massa. Phasellus pellentesque egestas dapibus.
  Proin porta tellus id orci consectetur bibendum. Nam eu cursus quam. Etiam
  vehicula in mi sed interdum. Duis rutrum eleifend consectetur. Phasellus
  ullamcorper, urna at vestibulum venenatis, tellus erat luctus nibh, eget
  hendrerit justo enim nec magna. Duis mollis ac felis ac tristique.

  Pellentesque malesuada arcu ac orci scelerisque vulputate. Aenean at ex
  suscipit, ultricies tellus sit amet, luctus lectus. Duis ut viverra sapien.
  Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac
  turpis egestas. Cras consequat nisi at ex finibus, in condimentum erat auctor.
  In at nulla at est iaculis pulvinar sed id diam. Cras malesuada sit amet tellus id molestie.

## cross-reference with citation syntax

* [**B1**]{#B1ref} This is the first claim.
* [B2]{#B2ref} This is the second claim.
* [*D*]{#Dref} This is the conclusion.

The claim @B1ref together with the claim @B2ref 
entail [@Dref].

## cross-reference with internal link syntax

* [**C1**]{#C1ref} This is the first claim.
* [C2]{#C2ref} This is the second claim.
* [*E*]{#Eref} This is the conclusion.

The claim [](#C1ref) together with the claim [](#C2ref) 
entail ([](#Eref)).


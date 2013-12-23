---
title : My Laravel3 Base Model
categories:
 - programming
tags :
 - php
 - laravel
---

I would like to share some code of my best practice to do model handling in Laravel 3.

First of all, here is my base model I usually extend from:

~~~php
<?php

class Base extends Eloquent {

  /**
  * @var
  */
  public static $timestamps = true;

  /**
  * @var
  */
  public $rules = array();

  /**
  * @var Laravel\Validator
  */
  private $validator = null;

  /**
  * Returns validation rules
  *
  * @return array
  */
  protected function getRules() {
    return $this->rules;
  }

  /**
  * Merge validation rule arrays
  *
  * @return void
  */
  protected function addRules($rules) {
    array_merge($rules, $this->rules);
  }

  /**
  * Returns instance of validator
  *
  * @return Laravel\Validator
  */
  public function getValidator() {
    if ($this->validator == null) {
      $this->validator = Validator::make($this->attributes, $this->getRules());
    }
    return $this->validator;
  }

  /**
  * Validates the model
  *
  * @return boolean
  */
  public function valid()
  {
    return $this->getValidator()->valid();
  }

  /**
  * Validates and saves the model
  *
  * @return void
  * @throw InvalidModelException
  */
  public function save()
  {
    if(! $this->valid()) {
      throw new InvalidModelException(get_class($this).' is not valid.');
    }
    parent::save();
  }

  /**
  * Return validation error messages
  *
  * @return array
  */
  public function getErrorMessages()
  {
    return $this->getValidator()->errors->all();
  }

  /**
  * Returns model as string
  *
  * @return string
  */
  public function __toString()
  {
    return $this->id;
  }
}

class InvalidModelException extends Exception {}
~~~

But let my explain, why I use it:

## Model Validation

In most online examples about validating, they show you how to validate a form. If the form values are valid, they put the values in a model. Think about it. Right, this is stupid. You want the model to be valid, not the form.

I show you how easy this can be. Here our model:

~~~php
class User extends Base 
{
  protected $rules = array(
    'name' => array('required'),
  );
}
~~~

How to validate:

~~~php
$user = new User();
$user->name = Input::get('name');

if (! $user->valid()) {
  // inform user about errors
}
~~~

The above example is to show you, how to validate a model. But this can even be easyier if you just like to save the model. The base model validates your model on save() by default;

~~~php
class User_Controller extends Base_Controller
{
  public function action_create()
  {
    try {
      $user = new User();
      $user->name = Input::get('name');
      $user->save();
      return Redirect::to_action('user@list')
        ->with('success', 'User '.$user.' successfully added!');
    } catch(InvalidModelException $e) {
      // We know, the validation failed, so we grab the validator.
      return Redirect::to_action('user@create')
        ->with_errors($user->getValidator());
    } catch (Exception $e) {
      // other exeption handling...
    }
  }
}
~~~

## Object to String

We often see something like 

~~~php
return Redirect::to_action('user@list')
  ->with('success', 'User '.$user->name.' successfully added!');
~~~

over and over again in the code. What if you you decide to also print out the id of the user too? There is a really handy so called Magic Method for this: __string().

If nothing is defined in your model, it will return the id.

~~~php
return Redirect::to_action('user@list')
  // User 1 successfully added
  ->with('success', 'User '.$user.' successfully added!');
~~~

Good enought as default. If you like to change this output, there is one place to change it: in your model!

~~~php
class User extends Base 
{
  ...
  public function __toString()
  {
    // e.g. John (ID: 1)
    return $user-name.' (ID: '.$user->id.')';
  }
  ...
}
~~~

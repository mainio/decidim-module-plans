# Decidim::Plans

[![Build Status](https://travis-ci.com/mainio/decidim-module-plans.svg?branch=master)](https://travis-ci.com/mainio/decidim-module-plans)
[![codecov](https://codecov.io/gh/mainio/decidim-module-plans/branch/master/graph/badge.svg)](https://codecov.io/gh/mainio/decidim-module-plans)

The gem has been developed by [Mainio Tech](https://www.mainiotech.fi/).

A [Decidim](https://github.com/decidim/decidim) module that provides a new
component that can be added to any participatory space in Decidim. The component
allows users to write plans together that link to specific proposals. Further on
these plans can be converted to budgeting projects once the process moves to
budgeting.

The idea of plans is for the people to plan together the proposals further
before a budgeting voting is started. During the planning process people should
come up with a more specific plan for the project based on which the budget can
be evaluated.

The plans component is based on the Decidim's own proposals component with the
following differences:

- Plans are multilingual so that they can be copied over to budgeting projects.
- Plans are collaborative by default, borrowing ideas from collaborative drafts
  in the proposals component.
- Plans can be linked to proposals in the same participatory space.
- The format of the plan form can be customized, so the fields that users need
  to fill can be customized instead of relying on a fixed set of fields. This
  allows all plans to appear in the same format.
- Plans can be later on converted into budgeting processes for the budgets
  component once they are finished. When converting, the different sections are
  converted to sub-headings in the budgeting project's description and the
  budget needs to be specified by the user doing the conversion.

Development of this gem has been sponsored by the
[City of Helsinki](https://www.hel.fi/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-plans'
```

And then execute:

```bash
$ bundle
$ bundle exec rails decidim_plans:install:migrations
$ bundle exec rails db:migrate
```

To keep the gem up to date, you can use the commands above to also update it.

## Usage

You can add the plans component to any participatory space. After adding, users
can start writing the plans when plan creation is enabled.

## Contributing

For instructions how to setup your development environment for Decidim, see [Decidim](https://github.com/decidim/decidim). Also follow Decidim's general
instructions for development for this project as well.

### Developing

To start contributing to this project, first:

- Install the basic dependencies (such as Ruby and PostgreSQL)
- Clone this repository

Decidim's main repository also provides a Docker configuration file if you
prefer to use Docker instead of installing the dependencies locally on your
machine.

You can create the development app by running the following commands after
cloning this project:

```bash
$ bundle
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake development_app
$ npm i
```

Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

Then to test how the module works in Decidim, start the development server:

```bash
$ cd development_app
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rails s
```

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add the environment variables to the root directory of the project in a file
named `.rbenv-vars`. If these are defined for the environment, you can omit
defining these in the commands shown above.

#### Code Styling

Please follow the code styling defined by the different linters that ensure we
are all talking with the same language collaborating on the same project. This
project is set to follow the same rules that Decidim itself follows.

The following linters are used:

- Ruby, [Rubocop](https://rubocop.readthedocs.io/)
- JS/ES, [eslint](https://eslint.org/)
- CSS/SCSS, [stylelint](https://stylelint.io/)

You can run the code styling checks by running the following commands from the
console:

```
$ bundle exec rubocop
$ npm run lint
$ npm run stylelint
```

To ease up following the style guide, you should install the plugins to your
favorite editor, such as:

- Atom
  * [linter-rubocop](https://atom.io/packages/linter-rubocop)
  * [linter-eslint](https://atom.io/packages/linter-eslint)
  * [linter-stylelint](https://atom.io/packages/linter-stylelint)
- Sublime Text
  * [Sublime RuboCop](https://github.com/pderichs/sublime_rubocop)
  * [SublimeLinter-eslint](https://github.com/SublimeLinter/SublimeLinter-eslint)
  * [SublimeLinter-stylelint](https://github.com/SublimeLinter/SublimeLinter-stylelint)
- Visual Studio Code
  * [Rubocop for Visual Studio Code](https://github.com/misogi/vscode-ruby-rubocop)
  * [VS Code ESLint extension](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
  * [vscode-stylelint](https://github.com/shinnn/vscode-stylelint)

### Testing

To run the tests run the following in the gem development path:

```bash
$ bundle
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake test_app
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rspec
```

Please read the notes regarding these commands from the development environment
setup above.

#### Test code coverage

If you want to generate the code coverage report for the tests, you can use
the `SIMPLECOV=1` environment variable in the rspec command as follows:

```bash
SIMPLECOV=1 bundle exec rspec
```

This will generate a folder named `coverage` in the project root which contains
the code coverage report.

### Localization

If you would like to see this module in your own language, you can help with its
translation at Crowdin:

https://crowdin.com/project/decidim-plans

## License

See [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt).

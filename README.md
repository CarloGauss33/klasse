# Klasse 
This is a Rails application, initially generated using [Potassium](https://github.com/platanus/potassium) by Platanus.

## Local installation

Assuming you've just cloned the repo, run this script to setup the project in your
machine:

    $ ./bin/setup

It assumes you have a machine equipped with Ruby, Node.js, Docker and make.

The script will do the following among other things:

- Install the dependecies
- Create a docker container for your database
- Prepare your database
- Adds heroku remotes

After the app setup is done you can run it with [Heroku Local]

    $ heroku local

[Heroku Local]: https://devcenter.heroku.com/articles/heroku-local


## Continuous Integrations

The project is setup to run tests
in [CircleCI](https://circleci.com/gh/platanus/klasse/tree/master)

You can also run the test locally simulating the production environment using [CircleCI's method](https://circleci.com/docs/2.0/local-cli/).


## Style Guides

Style guides are enforced through a CircleCI [job](.circleci/config.yml) with [reviewdog](https://github.com/reviewdog/reviewdog) as a reporter, using per-project dependencies and style configurations.
Please note that this reviewdog implementation requires a GitHub user token to comment on pull requests. A token can be generated [here](https://github.com/settings/tokens), and it should have at least the `repo` option checked.
The included `config.yml` assumes your CircleCI organization has a context named `org-global` with the required token under the environment variable `REVIEWDOG_GITHUB_API_TOKEN`.

The project comes bundled with configuration files available in this repository.

Linting dependencies like `rubocop` or `rubocop-rspec` must be locked in your `Gemfile`. Similarly, packages like `eslint` or `eslint-plugin-vue` must be locked in your `package.json`.

You can add or modify rules by editing the [`.rubocop.yml`](.rubocop.yml), [`.eslintrc.json`](.eslintrc.json) or [`.stylelintrc.json`](.stylelintrc.json) files.

You can (and should) use linter integrations for your text editor of choice, using the project's configuration.


## Seeds

To populate your database with initial data you can add, inside the `/db/seeds.rb` file, the code to generate **only the necessary data** to run the application.
If you need to generate data with **development purposes**, you can customize the `lib/fake_data_loader.rb` module and then to run the `rake load_fake_data` task from your terminal.


## Testing

We use:
- [RSpec](https://github.com/rspec/rspec-rails): the testing framework.
- [Shoulda Matchers](https://github.com/thoughtbot/shoulda-matchers): one-liners to test common Rails functionality that, if written by hand, would be much longer, more complex, and error-prone.
- [Factory Bot](https://github.com/thoughtbot/factory_bot_rails): a fixtures replacement with a straightforward definition syntax, support for multiple build strategies (saved instances, unsaved instances, attribute hashes, and stubbed objects), and support for multiple factories for the same class (user, admin_user, and so on), including factory inheritance.
- [Faker](https://github.com/faker-ruby/faker): a port of Perl's Data::Faker library that generates fake data.
- [Guard](https://github.com/guard/guard): automates various tasks by running custom rules whenever file or directories are modified. We use it to run RSpec when files change.

Place your unit tests inside the `spec` directory.

To run unit tests: `bin/guard`

#### System tests

We use, in addition to the previous gems:
- [Capybara](https://github.com/teamcapybara/capybara): helps you test web applications by simulating how a real user would interact with your app. It is agnostic about the driver running your tests and comes with Rack::Test and Selenium support built in. WebKit is supported through an external gem.
- [Webdrivers](https://github.com/titusfortner/webdrivers): run Selenium tests more easily with automatic installation and updates for all supported webdrivers.

Place your system tests inside the `spec/system` directory.

To run system tests: `bin/rspec --tag type:system`


## Internal dependencies

### Authorization

For defining which parts of the system each user has access to, we have chosen to include the [Pundit](https://github.com/elabs/pundit) gem, by [Elabs](http://elabs.se/).

### Authentication

We are using the great [Devise](https://github.com/plataformatec/devise) library by [PlataformaTec](http://plataformatec.com.br/)

### Administration

This project uses [Active Admin](https://github.com/activeadmin/activeadmin) which is a Ruby on Rails framework for creating elegant backends for website administration.


It uses the [ActiveAdmin's Pundit adapter](https://activeadmin.info/13-authorization-adapter.html).
- Policies for admin resources must inherit from `BackOffice::DefaultPolicy` and be placed inside the `app/policies/back_office` directory.
  - For example:

    `app/admin/clients.rb`:

    ```ruby
    ActiveAdmin.register Client do
      # ...
    end
    ```

    `app/policies/back_office/client_policy.rb`:

    ```ruby
    class BackOffice::ClientPolicy < BackOffice::DefaultPolicy
    end
    ```



### File Storage

For managing uploads, this project uses [Shrine](https://github.com/shrinerb/shrine). When generated, this project includes the following files and configurations:

- `ImageUploader` that includes file type validation
- `CoverImageUploader`, inheriting from `ImageUploader`. It does a couple of things:
  - Generates derivatives in `jpg` and `webp` format, for three different sizes. For an attachment of name `image`, to get the url for a derivative, let's say `sm`, you would do `record.image_url(:sm)`
  - Saves a [blurhash](https://blurha.sh/) code to the attachment metadata
- `ImageHandlingUtilities`, a shrine plugin in the initializers folder that is used in the `CoverImageUploader`. Given a model with an attachment of name `image`, it adds the following methods to the model:
  - `image_blurhash`: returns blurhash from metadata
  - `generate_image_derivatives`: It generates all derivatives defined in Uploader. If file already had derivatives, it replaces them with newly generated ones. Associated class method: `generate_all_image_derivatives`
  - `generate_image_metadata`: refreshes all metadata for attachment. Associated class method: `generate_all_image_metadata`
  - `generate_image_derivatives_and_metadata`: does both previous things. Useful because it does so opening the file only once. Associated class method: `generate_all_image_derivatives_and_metadata`

  Class methods are the same as their instance counterparts, but for collections. They also allow error handling on an individual record by passing a block to handle each error. If no block is given, attachments that throw errors are ignored and the iteration continues
- `ImageHandlingAttributes` serializer concern. It adds a method `add_image_handling_attributes` to all serializers that inherit from `BaseSerializer`. Considering an attachment of name `image`, this method adds two attributes to the serialized record:
  - `image_blurhash`
  - `image`. This is a hash that includes urls for all derivatives passed to the method. For example:
  ```
    add_image_handling_attributes(attachment_name: :image, derivatives: [:sm, :md], include_original_image: true)

    # results in the following hash for the image attribute:
    # {
    #   sm: { url: 'someurl.com/bla' },
    #   md: { url: 'someurl.com/ble' },
    #   original: { url: 'someurl.com/ble' }
    # }
  ```
- `SHRINE_SECRET_KEY` environment variable. It comes witha value set in `.env.development`, but you'll need to set one for it in staging and production. It can be any random value, generating it with `SecureRandom.hex` for instance


### Rails pattern enforcing types

This project uses [Power-Types](https://github.com/platanus/power-types) to generate Services, Commands, Utils and Values.

### Presentation Layer

This project uses [Draper](https://github.com/drapergem/draper) to add an object-oriented layer of presentation logic

### API Support

This projects uses [Power API](https://github.com/platanus/power_api). It's a Rails engine that gathers a set of gems and configurations designed to build incredible REST APIs.

## Development

For hot-reloading and fast webpacker compilation you need to run webpack's dev server along with the rails server:

    $ ./bin/webpacker-dev-server

Running the dev server will also solve problems with the cache not refreshing between changes and provide better error messages if something fails to compile.

For even faster in-place component refreshing (with no page reloads), you can enable Hot Module Reloading in `config/webpacker.yml`

    development:
      dev_server:
        hmr: true


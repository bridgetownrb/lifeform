# Lifeform

Component-centric form object rendering for Ruby. Bridgetown, Roda, and Rails all supported.

## Installation

Add Lifeform to your application's Gemfile by running:

```sh
bundle add lifeform
```

## Usage

Full documentation coming as the library begins to mature. TL;DR:

Given a form object of:

```rb
class TestForm < Lifeform::Form
  field :occupation, label: "Your Job", id: "your-occupation", required: true
  field :age, library: :shoelace, label: "Your Age"

  field :submit, type: :submit_button, label: "Save", class: "font-bold"
end
```

And a template rendering of:

```erb
<!-- ERB -->
<%= render TestForm.new(url: "/path") do |f| %>
  <%= render f.field(:occupation) %>
  <%= render f.field(:age, value: 47) %>
  <%= render f.field(:submit) %>
<% end %>
```

You get the following HTML output:

```html
<form method="post" accept-charset="UTF-8" action="/path">
  <input type="hidden" name="authenticity_token" value="[token]" />
  <form-field name="occupation">
    <label for="your-occupation">Your Job</label>
    <input type="text" id="your-occupation" required name="occupation" />
  </form-field>
  <form-field name="age">
    <sl-input type="text" label="Your Age" name="age" value="47" id="age"></sl-input>
  </form-field>
  <form-button name="commit">
    <button class="font-bold" name="commit" type="submit">Save</button>
  </form-button>
</form>
```

Nested names based on models (aka `profile[name]`) and inferred action paths are supported as well.

Multiple component libraries and input types—and easy customizability using string interpolation templates and helpers—are a fundamental aspect of the architecture of Lifeform. Until further docs have been written, you can look in `lib/lifeform/libraries` to see how some initial field types were constructed.

### Automatic Field Rendering

For simple forms, you can avoid the need to render fields individually in your template. Given the form example above, you could write in your template:

```erb
<%= render TestForm.new(url: "/path") %>
```

And the fields defined in `TestForm` would render out automatically (since no block was provided to the `render` method).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bin/rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bridgetownrb/lifeform. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/bridgetownrb/lifeform/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Lifeform project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bridgetownrb/lifeform/blob/main/CODE_OF_CONDUCT.md).

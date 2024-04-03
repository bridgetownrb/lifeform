# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.14.0] - 2024-03-03

- Add Rodauth support in Bridgetown

## [0.13.0] - 2024-03-15

- Fix rendering bug when wrapper tags were set to nil

## [0.12.0] - 2023-11-07

- Use new Streamlined gem for renderable features
  - Refactor to remove Phlex

## [0.11.0] - 2023-06-22

- Upgrade to Phlex 1.7+, Ruby 3.0+
- Provide a form-wide configuration object
- Allow field definitions to be added via `fields` block (useful for when you need to reference runtime configuration)

## [0.10.0] - 2022-12-23

- Support Phlex 1.0 and conditional `render_in` support for Bridgetown

## [0.9.0] - 2022-11-06

- Add button & submit button support for Shoelace

## [0.8.0] - 2022-10-09

- Add initializer for Bridgetown 1.2+
- Fix for Roda csrf

## [0.7.0] - 2022-09-30

- Rearchitect library to be built on top of the Phlex view library

## [0.5.0] - 2022-06-10

## [0.4.0] - 2022-06-08

- Add support for submit buttons

## [0.3.0] - 2022-06-08

- Add automatic field rendering

## [0.2.0] - 2022-05-31

- Fields now support content blocks, conditional rendering
- Form subclass will now inherit parent form library

## [0.1.0] - 2022-05-29

- Initial release

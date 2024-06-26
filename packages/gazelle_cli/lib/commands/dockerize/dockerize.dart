import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_spin/cli_spin.dart';

import '../../commons/functions/load_project_configuration.dart';
import 'create_docker_files.dart';

const _defaultExposedPort = 3000;

/// Creates docker file for current project.
Future<File> dockerize({
  int? exposedPort,
}) async {
  final config = await loadProjectConfiguration();
  return createDockerFiles(
    path: Directory.current.path,
    mainFilePath: "bin/${config.name}.dart",
    exposedPort: exposedPort ?? _defaultExposedPort,
  );
}

/// CLI command to dockerize project.
class DockerizeCommand extends Command {
  @override
  String get name => "dockerize";
  @override
  String get description => "Generates Dockerfile for current project.";

  /// Creates a [DockerizeCommand].
  DockerizeCommand() {
    argParser.addOption(
      "port",
      abbr: "p",
      help: "Specifies exposed port in Dockerfile.",
      defaultsTo: "3000",
    );
  }

  @override
  Future<void> run() async {
    final spinner = CliSpin(
      text: "Creating Dockerfile...",
      spinner: CliSpinners.dots,
    ).start();

    final portOption = argResults?.option("port");
    final exposedPort = portOption != null ? int.tryParse(portOption) : null;

    try {
      final dockerfile = await dockerize(exposedPort: exposedPort);
      spinner.success("Dockerfile created at ${dockerfile.path}");
    } on LoadProjectConfigurationError catch (e) {
      spinner.fail(e.errorMessage);
      exit(e.errorCode);
    } on Exception catch (e) {
      spinner.fail(e.toString());
      exit(2);
    }
  }
}

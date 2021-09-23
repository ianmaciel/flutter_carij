// MIT License

// Copyright (c) 2021 Anonymized Developer

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'package:flutter/foundation.dart';
import 'package:flutter_carij/src/settings/settings_controller.dart';

import 'package:gitlab/gitlab.dart';

class GitlabProvider extends ChangeNotifier {
  final SettingsController _settingsController;
  late GitLab gitLab;
  late ProjectsApi gitLabProject;
  List<Issue>? issues;
  String get token => _settingsController.gitlabToken;
  int get projectId => _settingsController.gitlabProjectId;
  GitlabProvider(this._settingsController) {
    init();
  }

  void setProjetId(String newProjectId) =>
      _settingsController.updateGitlabProjectId(int.tryParse(newProjectId));
  void setToken(String newToken) =>
      _settingsController.updateGitlabToken(newToken);

  void init({String? token, String? projectId}) {
    if (token != null) {
      setToken(token);
    }
    if (projectId != null) {
      setProjetId(projectId);
    }

    if (this.token.isNotEmpty) {
      gitLab = GitLab(this.token);
      gitLabProject = gitLab.project(this.projectId);
      getIssues();
    }
  }

  void getIssues() {
    gitLabProject.issues.list(page: 0, perPage: 30).then(updateIssues);
  }

  void updateIssues(List<Issue> issues) {
    this.issues = issues;
    // TODO: mocked, remove this.
    loadIssue(issues.first.iid!);
    notifyListeners();
  }

  void loadIssue(int id) {
    gitLabProject.issues.get(id).then(onIssueLoaded);
  }

  void onIssueLoaded(Issue issue) {
    // TODO
    Issue newIssue = issue;
  }

  void createIssue(String title) async {
    Issue created = await gitLabProject.issues.add(title);
    issues!.add(created);
    notifyListeners();
  }
}

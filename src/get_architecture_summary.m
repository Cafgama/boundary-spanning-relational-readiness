function GS = get_architecture_summary(all_GS, architecture)
  % GET_ARCHITECTURE_SUMMARY
  % Retrieves one graph-level summary by architecture name.
  %
  % Inputs:
  %   all_GS        cell array of graph-summary structures
  %   architecture  requested architecture name
  %
  % Output:
  %   GS            matching graph-summary structure

  assert(iscell(all_GS), 'all_GS must be a cell array.');
  assert(ischar(architecture), ...
    'architecture must be a character string.');

  matching_indices = [];

  for i = 1:length(all_GS)
    assert(isstruct(all_GS{i}), ...
      'Each element of all_GS must be a structure.');

    assert(isfield(all_GS{i}, 'architecture'), ...
      'Each graph summary must contain architecture.');

    if strcmp(all_GS{i}.architecture, architecture)
      matching_indices(end + 1) = i;
    end
  end

  assert(length(matching_indices) == 1, ...
    ['Expected exactly one summary for architecture: ', architecture]);

  GS = all_GS{matching_indices(1)};
end

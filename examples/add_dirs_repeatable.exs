Code.require_file("support/example_helper.exs", __DIR__)

alias AntigravityCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("add_dirs_repeatable", config)

dir_a = Helper.tmp_dir!("agy-add-dir-a")
dir_b = Helper.tmp_dir!("agy-add-dir-b")
args = Helper.render_args(config, [add_dirs: [dir_a, dir_b]], "Add dir render")

Helper.assert_arg_pair(args, "--add-dir", dir_a)
Helper.assert_arg_pair(args, "--add-dir", dir_b)

count =
  args
  |> Enum.count(&(&1 == "--add-dir"))

IO.puts("add_dir_flag_count=#{count}")

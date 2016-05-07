task :clear_metrics do |_t|
  ret =
    system('git checkout coverage/.last_run.json metrics/*_high_water_mark')
  fail unless ret
end

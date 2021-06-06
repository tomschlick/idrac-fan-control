<?php

namespace App\Commands;

use Illuminate\Console\Scheduling\Schedule;
use LaravelZero\Framework\Commands\Command;

class AutoControlFansCommand extends Command
{
    /**
     * The signature of the command.
     *
     * @var string
     */
    protected $signature = 'fans:daemon';

    /**
     * The description of the command.
     *
     * @var string
     */
    protected $description = 'Daemon to auto watch and control the target system.';

    /**
     * Execute the console command.
     *
     * @return mixed
     */
    public function handle()
    {
        while (true) {
            $this->line("Testing...");

            $IPMIHOST = env('IPMIHOST');
            $IPMIUSER = env('IPMIUSER');
            $IPMIPW = env('IPMIPW');
            $SENSOR = "Temp";

            var_dump($IPMIHOST, $IPMIUSER, $IPMIPW, $SENSOR);

            /** @var \App\IPMI $ipmi */
            $ipmi = app('ipmi');



//             $output = $ipmi->getTemperatures();
             $output = $ipmi->setFanModeAutomatic();
//             $ipmi->setFanModeManual();
//             $output = $ipmi->setFanSpeedWithPercentage(80);

            var_dump($output);

            $this->line('Sleeping...');
            sleep(env('SLEEP'));
        }
    }
}

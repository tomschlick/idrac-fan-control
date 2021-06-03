<?php

namespace App\Providers;

use App\IPMI;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        //
    }

    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        $this->app->singleton('ipmi', function() {
            return new IPMI(
                env('IPMIHOST'),
                env('IPMIUSER'),
                env('IPMIPW')
            );
        });
    }
}

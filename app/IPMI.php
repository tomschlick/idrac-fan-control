<?php

declare(strict_types=1);

namespace App;

use Illuminate\Support\Facades\Log;

class IPMI
{
    protected string $ipmi_host;

    protected string $ipmi_user;

    protected string $ipmi_password;

    public function __construct(string $ipmi_host, string $ipmi_user, string $ipmi_password)
    {
        $this->ipmi_host = $ipmi_host;
        $this->ipmi_user = $ipmi_user;
        $this->ipmi_password = $ipmi_password;
    }

    private function executeCommand(string $command): ?string
    {
        return shell_exec($this->generateCommand($command));
    }

    protected function generateCommand(string $command): string
    {
        return "ipmitool -I lanplus -H $this->ipmi_host -U $this->ipmi_user -P $this->ipmi_password $command";
    }

    public function getTemperatures(): string
    {
        return $this->executeCommand("sdr type temperature");
    }

    public function getFanSpeeds(): string
    {
        return $this->executeCommand("sdr type fan");
    }

    public function setFanModeAutomatic(): void
    {
        $this->executeCommand("raw 0x30 0x30 0x01 0x01");
        Log::info("Set fan speeds mode to AUTOMATIC");
    }

    public function setFanModeManual(): void
    {
        $this->executeCommand("raw 0x30 0x30 0x01 0x00");
    }

    public function setFanSpeedWithPercentage(int $percentage): void
    {
        $this->setFanSpeedWithHex($this->generateHexFromPercentage($percentage));
    }

    public function generateHexFromPercentage(int $percentage): string
    {
        return str_pad(dechex($percentage), 2, "0", STR_PAD_LEFT);
    }

    public function setFanSpeedWithHex(string $hex): void
    {
        $this->executeCommand("raw 0x30 0x30 0x02 0xff 0x$hex");
    }
}

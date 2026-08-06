<?php

namespace App\Filament\Resources\PassengerSessionResource\Pages;

use App\Filament\Resources\PassengerSessionResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditPassengerSession extends EditRecord
{
    protected static string $resource = PassengerSessionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}

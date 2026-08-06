<?php

namespace App\Filament\Resources\RunningTextResource\Pages;

use App\Filament\Resources\RunningTextResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;
use Filament\Resources\Components\Tab;
use Illuminate\Database\Eloquent\Builder;

class ListRunningTexts extends ListRecords
{
    protected static string $resource = RunningTextResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }

    public function getTabs(): array
    {
        return [
            'all' => Tab::make('All Running Texts')
                ->badge(fn () => \App\Models\RunningText::count()),

            'active' => Tab::make('Currently Active')
                ->badge(fn () => \App\Models\RunningText::currentlyActive()->count())
                ->badgeColor('success')
                ->modifyQueryUsing(fn (Builder $query) => $query->currentlyActive()),

            'top' => Tab::make('Top Position')
                ->badge(fn () => \App\Models\RunningText::where('position', 'top')->count())
                ->modifyQueryUsing(fn (Builder $query) => $query->where('position', 'top')),

            'bottom' => Tab::make('Bottom Position')
                ->badge(fn () => \App\Models\RunningText::where('position', 'bottom')->count())
                ->modifyQueryUsing(fn (Builder $query) => $query->where('position', 'bottom')),

            'inactive' => Tab::make('Inactive')
                ->badge(fn () => \App\Models\RunningText::where('is_active', false)->count())
                ->badgeColor('danger')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('is_active', false)),
        ];
    }
}

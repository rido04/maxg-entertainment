<?php

namespace App\Filament\Resources;

use Filament\Forms;
use Filament\Tables;
use Filament\Forms\Form;
use Filament\Tables\Table;
use Filament\Resources\Resource;
use App\Models\PassengerSession;
use Filament\Tables\Filters\Filter;
use Filament\Tables\Filters\SelectFilter;
use Illuminate\Database\Eloquent\Builder;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Actions\ViewAction;
use Filament\Infolists\Infolist;
use Filament\Infolists\Components\Section;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Components\RepeatableEntry;
use App\Filament\Resources\PassengerSessionResource\Pages;

class PassengerSessionResource extends Resource
{
    protected static ?string $model = PassengerSession::class;

    protected static ?string $navigationIcon = 'heroicon-o-user-group';

    protected static ?string $navigationLabel = 'Passenger Sessions';

    protected static ?string $navigationGroup = 'Analytics';

    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Session Information')
                    ->schema([
                        Forms\Components\TextInput::make('session_id')
                            ->label('Session ID')
                            ->disabled(),

                        Forms\Components\TextInput::make('device_id')
                            ->label('Device ID')
                            ->disabled(),

                        Forms\Components\TextInput::make('driver_id')
                            ->label('Driver ID')
                            ->disabled(),
                    ])
                    ->columns(3),

                Forms\Components\Section::make('Demographics')
                    ->schema([
                        Forms\Components\TextInput::make('gender')
                            ->label('Gender')
                            ->disabled(),

                        Forms\Components\TextInput::make('age_group')
                            ->label('Age Group')
                            ->disabled(),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Time & Duration')
                    ->schema([
                        Forms\Components\DateTimePicker::make('start_time')
                            ->label('Start Time')
                            ->disabled(),

                        Forms\Components\DateTimePicker::make('end_time')
                            ->label('End Time')
                            ->disabled(),

                        Forms\Components\TextInput::make('duration_seconds')
                            ->label('Duration (seconds)')
                            ->disabled()
                            ->suffix('seconds'),
                    ])
                    ->columns(3),

                Forms\Components\Section::make('Ad Engagement')
                    ->schema([
                        Forms\Components\TextInput::make('ad_view_count')
                            ->label('Ads Viewed')
                            ->disabled(),

                        Forms\Components\Textarea::make('viewed_ads')
                            ->label('Viewed Ads Details')
                            ->disabled()
                            ->formatStateUsing(function ($state) {
                                // Decode jika string JSON
                                $viewedAds = is_string($state)
                                    ? json_decode($state, true)
                                    : $state;
                                return json_encode($viewedAds, JSON_PRETTY_PRINT);
                            }),
                    ])
                    ->columns(1),
            ]);
    }

    public static function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Section::make('Session Information')
                    ->schema([
                        TextEntry::make('session_id')
                            ->label('Session ID')
                            ->copyable(),

                        TextEntry::make('device_id')
                            ->label('Device ID'),

                        TextEntry::make('driver_id')
                            ->label('Driver ID')
                            ->default('N/A'),
                    ])
                    ->columns(3),

                Section::make('Demographics')
                    ->schema([
                        TextEntry::make('gender')
                            ->label('Gender')
                            ->badge()
                            ->color(fn (string $state): string => match ($state) {
                                'male' => 'info',
                                'female' => 'warning',
                                'unknown' => 'gray',
                            }),

                        TextEntry::make('age_group')
                            ->label('Age Group')
                            ->badge()
                            ->color('success')
                            ->default('N/A'),
                    ])
                    ->columns(2),

                Section::make('Time & Duration')
                    ->schema([
                        TextEntry::make('start_time')
                            ->label('Start Time')
                            ->dateTime('d M Y, H:i:s'),

                        TextEntry::make('end_time')
                            ->label('End Time')
                            ->dateTime('d M Y, H:i:s')
                            ->default('N/A'),

                        TextEntry::make('duration_seconds')
                            ->label('Duration')
                            ->formatStateUsing(function ($state) {
                                $minutes = floor($state / 60);
                                $seconds = $state % 60;
                                return sprintf('%02d:%02d', $minutes, $seconds);
                            })
                            ->suffix(' (mm:ss)'),
                    ])
                    ->columns(3),

                Section::make('Ad Engagement')
                    ->schema([
                        TextEntry::make('ad_view_count')
                            ->label('Total Ads Viewed')
                            ->badge()
                            ->color('success')
                            ->size('lg'),

                        RepeatableEntry::make('viewed_ads')
                            ->label('Viewed Advertisements')
                            ->schema([
                                TextEntry::make('ad_id')
                                    ->label('Ad ID')
                                    ->badge()
                                    ->color('info'),

                                TextEntry::make('ad_title')
                                    ->label('Ad Title')
                                    ->weight('bold')
                                    ->color('primary'),

                                TextEntry::make('viewed_at')
                                    ->label('Viewed At')
                                    ->dateTime('H:i:s')
                                    ->size('sm'),

                                TextEntry::make('duration_seconds')
                                    ->label('Duration')
                                    ->suffix('s')
                                    ->default('N/A')
                                    ->size('sm'),
                            ])
                            ->columns(4)
                            ->columnSpanFull()
                            ->hidden(fn ($record) => empty($record->viewed_ads)),
                    ])
                    ->columns(1),

                Section::make('Metadata')
                    ->schema([
                        TextEntry::make('metadata')
                            ->label('Additional Data')
                            ->formatStateUsing(function ($state) {
                                // Decode jika string JSON
                                $metadata = is_string($state)
                                    ? json_decode($state, true)
                                    : $state;
                                return json_encode($metadata, JSON_PRETTY_PRINT);
                            })
                            ->default('{}'),
                    ])
                    ->collapsible()
                    ->collapsed(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('session_id')
                    ->label('Session ID')
                    ->searchable()
                    ->limit(20)
                    ->tooltip(fn ($record) => $record->session_id),

                TextColumn::make('device_id')
                    ->label('Device')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('start_time')
                    ->label('Start Time')
                    ->dateTime('d M Y, H:i')
                    ->sortable(),

                TextColumn::make('duration_seconds')
                    ->label('Duration')
                    ->formatStateUsing(function ($state) {
                        $minutes = floor($state / 60);
                        $seconds = $state % 60;
                        return sprintf('%02d:%02d', $minutes, $seconds);
                    })
                    ->sortable()
                    ->alignCenter(),

                TextColumn::make('gender')
                    ->label('Gender')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'male' => 'info',
                        'female' => 'warning',
                        'unknown' => 'gray',
                    })
                    ->icon(fn (string $state): string => match ($state) {
                        'male' => 'heroicon-o-user',
                        'female' => 'heroicon-o-user',
                        'unknown' => 'heroicon-o-question-mark-circle',
                    })
                    ->sortable(),

                TextColumn::make('age_group')
                    ->label('Age Group')
                    ->badge()
                    ->color('success')
                    ->default('N/A')
                    ->sortable(),

                TextColumn::make('ad_view_count')
                    ->label('Ads Viewed')
                    ->alignCenter()
                    ->sortable()
                    ->summarize(Tables\Columns\Summarizers\Sum::make()),

                TextColumn::make('viewed_ads')
                    ->label('Ad Titles')
                    ->formatStateUsing(function ($state) {
                        if (empty($state)) {
                            return 'No ads viewed';
                        }

                        // Decode jika string JSON
                        $viewedAds = is_string($state)
                            ? json_decode($state, true)
                            : $state;

                        if (empty($viewedAds)) {
                            return 'No ads viewed';
                        }

                        // Ambil hanya 2 ad titles pertama
                        $titles = collect($viewedAds)
                            ->take(2)
                            ->pluck('ad_title')
                            ->join(', ');

                        $count = count($viewedAds);
                        if ($count > 2) {
                            $titles .= " (+".($count - 2)." more)";
                        }

                        return $titles;
                    })
                    ->limit(50)
                    ->tooltip(function ($record) {
                        if (empty($record->viewed_ads)) {
                            return null;
                        }

                        // Decode jika string JSON
                        $viewedAds = is_string($record->viewed_ads)
                            ? json_decode($record->viewed_ads, true)
                            : $record->viewed_ads;

                        if (empty($viewedAds)) {
                            return null;
                        }

                        return collect($viewedAds)
                            ->pluck('ad_title')
                            ->join("\n");
                    })
                    ->wrap()
                    ->toggleable(),

                TextColumn::make('created_at')
                    ->label('Logged At')
                    ->dateTime('d M Y, H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('start_time', 'desc')
            ->filters([
                SelectFilter::make('gender')
                    ->options([
                        'male' => 'Male',
                        'female' => 'Female',
                        'unknown' => 'Unknown',
                    ])
                    ->multiple(),

                SelectFilter::make('age_group')
                    ->options([
                        'child' => 'Child',
                        'teen' => 'Teen',
                        'adult' => 'Adult',
                        'senior' => 'Senior',
                    ])
                    ->multiple(),

                Filter::make('start_time')
                    ->form([
                        Forms\Components\DatePicker::make('from')
                            ->label('From Date'),
                        Forms\Components\DatePicker::make('to')
                            ->label('To Date'),
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        return $query
                            ->when(
                                $data['from'],
                                fn (Builder $query, $date): Builder => $query->whereDate('start_time', '>=', $date),
                            )
                            ->when(
                                $data['to'],
                                fn (Builder $query, $date): Builder => $query->whereDate('start_time', '<=', $date),
                            );
                    }),

                Filter::make('today')
                    ->query(fn (Builder $query): Builder => $query->whereDate('start_time', today()))
                    ->toggle(),

                Filter::make('this_week')
                    ->query(fn (Builder $query): Builder => $query->thisWeek())
                    ->toggle(),

                Filter::make('this_month')
                    ->query(fn (Builder $query): Builder => $query->thisMonth())
                    ->toggle(),
            ])
            ->actions([
                ViewAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListPassengerSessions::route('/'),
            'view' => Pages\ViewPassengerSession::route('/{record}'),
        ];
    }

    // Disable create/edit since this is analytics data
    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit($record): bool
    {
        return false;
    }
}
